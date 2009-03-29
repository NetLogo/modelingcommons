require 'zip/zip'
require 'diff/lcs'
require 'diff/lcs/string'
require 'diff/lcs/hunk'

class BrowseController < ApplicationController

  prepend_before_filter :get_model_from_id_param, :except => [:index, :list_models, :list_models_group, :search, :search_action, :news, :one_node, :create_group, :whats_new, :about, :stuff, :spider, :view_random_model]
  before_filter :require_login, :except => [:model_contents, :one_applet, :about, :follow]
  before_filter :check_visibility_permissions, :only => [:one_model, :model_contents, :one_applet ]
  before_filter :check_changeability_permissions, :only => [:revert_model]

  def index
    @postings = Posting.find(:all,
                             :conditions => "is_question = true")
  end

  def list_models
    @models = Node.paginate(:page => params[:page],
                            :order => 'name ASC',
                            :conditions => "node_type_id = 1")
  end

  def list_models_group
    if params[:id].blank?
      @group_ids = @person.groups.map {|g| g.id}.join(',')
      @title = "List of models in all of your groups"
    else
      @group_ids = params[:id]
      @group = Group.find(@group_ids)
      @title = "List of models in the '#{@group.name}' group"
    end

    @models = Node.paginate(:page => params[:page], :order => 'name ASC', :conditions => [ "node_type_id = 1 and group_id in (#{@group_ids}) "])
  end

  def one_model
    if @model.nil?
      render :text => "No model found with ID '#{params[:id]}'"
      return
    end

    @recommendations = Recommendation.find_all_by_node_id(@model.id) || []
    @spam_warnings = SpamWarning.find_all_by_node_id(@model.id) || []
  end

  def one_model_tabs
    if @model.nil?
      render :text => "No model found with ID '#{params[:id]}'"
      return
    end

    @recommendations = Recommendation.find_all_by_node_id(@model.id) || []
    @spam_warnings = SpamWarning.find_all_by_node_id(@model.id) || []
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

    if @model.latest_preview.blank?
      redirect_to "/images/no-preview.png"
      return
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
              :type => 'application/zip',
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
      redirect_to :back, :anchor => "history-div"
      return
    end

    # Check that we're not reverting to the latest version!
    version = NodeVersion.find(version_id)
    if version == @model.current_version
      flash[:notice] = "That is already the current version!"
      redirect_to :back, :anchor => "history-div"
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

    redirect_to :back, :anchor => "history-div"
  end

  def search_action
    if params[:search_term].blank?
      flash[:notice] = "You must enter a search term in order to search."
      redirect_to :controller => :account, :action => :mypage
      return
    end

    logger.warn "[search_action] Now starting search_action"
    @original_search_term = params[:search_term][:search_term]

    @models = Node.find(:all, :conditions => "node_type_id = 1").select {|m| m.name.downcase.index(@original_search_term.downcase)}

    @ferret_results = NodeVersion.find_by_contents(@original_search_term).map {|nv| nv.node}.uniq

    @info_match_models = @ferret_results.select { |r| r.info_tab.downcase.index(@original_search_term.downcase)}

    logger.warn "[search_action] Now checking @author_match_models"
    @author_match_models = Node.find(:all, :conditions => "node_type_id = 1").select {|m| m.people.map { |person| person.fullname}.join(" ").downcase.index(@original_search_term.downcase)}

    @procedures_match_models = @ferret_results.select { |r| r.procedures_tab.downcase.index(@original_search_term.downcase)}

    logger.warn "[search_action] Now checking @tag_match_models"
    @tag_match_models =
      Node.models.find_all {|m| m.tags.map { |t| t.name}.join(' ').downcase.index(@original_search_term.downcase)}

  end

  def news
    @news_items = NewsItem.find(:all, :order => "created_at DESC")
  end

  def compare_versions
    @version_1 = NodeVersion.find(params[:compare_1])
    @version_2 = NodeVersion.find(params[:compare_2])

    if @version_1 == @version_2
      flash[:notice] = "You cannot compare a version with itself!"
      redirect_to :back
      return
    end

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
    if params[:read_permission].blank? or params[:write_permission].blank?
      flash[:notice] = 'Both read and write permissions must be specified. '
    else

      read_permission = PermissionSetting.find_by_short_form(params[:read_permission])
      write_permission = PermissionSetting.find_by_short_form(params[:write_permission])

      Model.transaction do

        # Set the read permissions
        @model.visibility_id = read_permission.id
        @model.changeability_id = write_permission.id

        if params[:group] and params[:group][:id]
          if params[:group][:id].to_i == 0
            @model.group = nil
          else
            @model.group = Group.find(params[:group][:id])
          end
        end

        if @model.save
          @outcome = 'good'
        else
          @outcome = 'bad'
        end
      end
    end
  end

  def whats_new
    @all_whats_new = all_whats_new
  end


  def as_tree

  end

  def follow
    @new_things = [ ]
    how_recent = 6.months.ago

    @node.node_versions.find(:all, :conditions => ["created_at >= ? ", how_recent]).each do |nv|

      @new_things <<
        {:id => nv.id,
        :node_id => nv.node_id,
        :node_name => nv.node.name,
        :date => nv.created_at,
        :description => "New version of '#{nv.node.name}' uploaded by '#{nv.person.fullname}'",
        :title => "Update to model '#{nv.node.name}'",
        :contents => nv.description}
    end

    @node.postings.find(:all, :conditions => ["created_at >= ? ", how_recent]).each do |posting|

      @new_things <<
        {:id => posting.id,
        :node_id => posting.node_id,
        :node_name => posting.node.name,
        :date => posting.created_at,
        :description => "Posting by '#{posting.person.fullname}' about the '#{posting.node.name}' model",
        :title => posting.title,
        :contents => posting.body}
    end

    @node.tagged_nodes.find(:all, :conditions => ["created_at >= ? ", how_recent]).each do |tn|

      @new_things <<
        {:id => tn.id,
        :node_id => tn.node_id,
        :node_name => tn.node.name,
        :date => tn.created_at,
        :description => "Model '#{tn.node.name}' tagged with '#{tn.tag.name}' by '#{tn.person.fullname}'",
        :title => "Model '#{tn.node.name}' tagged with '#{tn.tag.name}' by '#{tn.person.fullname}'",
        :contents => "<p>'#{tn.person.fullname} tagged the '#{tn.node.name}' model</p>"
      }
    end

    respond_to do |format|
      format.html { @new_things }
      format.atom { @new_things }
    end
  end

  def view_random_model
    redirect_to :controller => :browse, :action => :one_model, :id => Node.models.rand.id
  end

  # ------------------------------------------------------------
  # Below here is PRIVATE!
  # ------------------------------------------------------------

  private
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
