require 'zip/zip'
require 'diff/lcs'
require 'diff/lcs/string'
require 'diff/lcs/hunk'

class BrowseController < ApplicationController

  before_filter :require_login, :except => [:model_contents, :one_applet]
  before_filter :get_model_from_id_param, :except => [:index, :list_models, :search, :search_action, :news, :one_node, :create_group]
  before_filter :check_visibility_permissions, :only => [:one_model, :model_contents, :one_applet ]
  before_filter :check_changeability_permissions, :only => [:revert_model]

  def index
    @postings = Posting.find(:all,
                             :conditions => "is_question = true")
  end

  def list_models
    @models = Node.models.find(:all, :order => 'name')
  end

  def one_model
    if @model.nil?
      render :text => "No model found with ID '#{params[:id]}'"
      return
    end

  end

  def one_node
    if params[:id].blank?
      flash[:notice] = "No node ID passed. "
      redirect_to :back
      return
    end

    node = Node.find(params[:id])
    node_type = node.node_type


    if node.node_type_id == 1
      redirect_to :action => :one_model, :id => params[:id]
      return

    elsif node.node_type_id == 2
      redirect_to :action => :display_preview, :id => node.parent.id
      return

    else
      send_data node.contents, :type => 'application/binary'
    end
  end

  def display_preview
    if params[:id].blank?
      render :text => "No model ID provided"
      return
    end

    #xyz = Node.find(params[:id])
    #render :text => xyz.children.last.node_versions.sort { |n| n.created_at}.last.contents
    #return

    if @model.latest_preview.empty?
      render :text => "This model has no preview image"
    else
      send_data(@model.latest_preview, :type => 'image/png', :disposition => 'inline')
    end
  end

  def download_model
    download_model_name = @model.name.gsub(' ', '_')
    zipfile_name = "#{RAILS_ROOT}/public/modelzips/#{download_model_name}.zip"

    logger.warn "Zipfile name = '#{zipfile_name}'"

    # Create the zipfile
    Zip::ZipOutputStream::open(zipfile_name) do |io|
      io.put_next_entry("#{download_model_name}.nlogo")
      io.write(@model.contents)

      # Now we get all child nodes that are not themselves models.
      @model.non_models.each do |child|
        io.put_next_entry("#{child.filename}")
        io.write(child.contents)
      end
    end

    send_file(zipfile_name,
              :filename => "#{download_model_name}.zip",
              :disposition => "inline")
  end

  def procedures_tab
    @procedures_tab_contents = @model.procedures_tab
  end

  def gui_tab
    @gui_tab_contents = @model.gui_tab
  end

  def info_tab
    @info_tab_contents = @model.info_tab

    @info_tab_contents.gsub!(/http:\/\/\S+/) { |url| "<a href='#{url}' target='_blank'>#{url}</a>"}
    @info_tab_contents.gsub!("\n\n", "<p>\n\n</p>")
    @info_tab_contents.gsub!(/^[A-Z ?]+$/) { |headline| "<h2>#{headline.capitalize}</h2>"}
    @info_tab_contents.gsub!(/^-+$/, '')
  end

  def model_contents
    send_data @model.contents
  end

  def revert_model
    # Make sure that we got an older version
    version_id = params[:version]
    if version_id.blank?
      flash[:notice] = "Sorry, but you must specify a version to which you want to revert."
      redirect_to :back
      return
    end

    # Check that we're not reverting to the latest version!
    version = NodeVersion.find(version_id)
    if version == @model.current_version
      flash[:notice] = "That is already the current version!"
      redirect_to :back
      return
    end

    @new_version =
      NodeVersion.create(:nlmodel_id => @model.id,
                         :person_id => @person.id,
                         :contents => version.contents,
                         :note => "Reverted to older version")
    if @new_version.save
      flash[:notice] = "Model was reverted to an older version"
    else
      flash[:notice] = "Error reverting the model; nothing was changed."
    end

    redirect_to :back
  end

  def search_action
    @original_search_term = params[:search_term][:search_term]
    search_term = "%#{@original_search_term}%"

    @models = Node.models.find(:all,
                               :conditions => ["name ilike ? ", search_term],
                               :order => 'name')

    # @info_match_models = Node.models.find_all {|m| m.info_tab and m.info_tab.downcase.index(@original_search_term.downcase)}

    @author_match_models =
      Node.models.find_all {|m| m.people.map {|pid| Person.find(pid).fullname}.join(" ").downcase.index(@original_search_term.downcase)}

    #    @procedures_match_models = Node.models.find_all {|m| m.procedures_tab and m.procedures_tab.downcase.index(@original_search_term.downcase)}

    @tag_match_models =
      Node.models.find_all {|m| m.tags.map { |t| t.name}.join(' ').downcase.index(@original_search_term.downcase)}

  end

  def news
    @news_items = NewsItem.find(:all, :order => "created_at DESC")
  end

  def rss
    @updates = NodeVersion.find(:all,
                                :limit => 25,
                                :order => "updated_at DESC")
  end

  def compare_versions
    @version_1 = NodeVersion.find(params[:compare_1])
    @version_2 = NodeVersion.find(params[:compare_2])

    @comparison_results = { }
    @comparison_results['info_tab'] =
      diff_as_string(@version_1.info_tab, @version_2.info_tab)

    # @comparison_results['gui_tab'] =
    #diff_as_string(@version_1.gui_tab, @version_2.gui_tab)

    # @comparison_results['procedures_tab'] =
    # diff_as_string(@version_1.procedures_tab, @version_2.procedures_tab)
  end

  def one_applet
  end

  def set_permissions
    if params[:read_permission].empty? or params[:write_permission].empty?
      flash[:notice] = 'Both read and write permissions must be specified. '
    else

      read_permission = PermissionSetting.find_by_short_form(params[:read_permission])
      write_permission = PermissionSetting.find_by_short_form(params[:write_permission])

      Model.transaction do

        # Set the read permissions
        @model.visibility_id = read_permission.id
        @model.changeability_id = write_permission.id

        if params[:group] and params[:group][:id]
          @model.group = Group.find(params[:group][:id])
        end

        if @model.save
          flash[:notice] = "Successfully set permissions for '#{@model.name}'. "
        else
          flash[:notice] = "Error setting permissions for '#{@model.name}': "
          @model.errors.each do |error|
            flash[:notice] << error
          end
        end
      end
    end

    redirect_to :back
  end

  # ------------------------------------------------------------
  # Below here is PRIVATE!
  # ------------------------------------------------------------

  private
  def get_model_from_id_param
    if params[:id].blank?
      flash[:notice] = "No model ID provided"
      redirect_to :back
      return
    end

    @model = Node.models.find(params[:id])
    @node = @model
  rescue
    render :text => "No model with ID '#{params[:id]}'"
    return
  end

  def diff_as_string(data_old, data_new, format=:unified, context_lines=1)
    data_old = data_old.split(/\n/).map! { |e| e.chomp}
    data_new = data_new.split(/\n/).map! { |e| e.chomp}

    output = ''
    diffs = Diff::LCS.diff(data_old,data_new)

    return output if diffs.empty?
    oldhunk = hunk = nil
    file_length_difference = 0

    diffs.each do |piece|
      begin
        hunk = Diff::LCS::Hunk.new(data_old, data_new, piece, context_lines,
                                   file_length_difference)
        file_length_difference = hunk.file_length_difference
        next unless oldhunk

        if (context_lines > 0) and hunk.overlaps?(oldhunk)
          hunk.unshift(oldhunk)
        else
          output << oldhunk.diff(format)
        end
      ensure
        oldhunk = hunk
        output << "\n"
      end
    end

    output << oldhunk.diff(format) << "\n"
  end

end
