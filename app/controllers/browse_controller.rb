require 'zip/zip'
require 'diff/lcs'
require 'diff/lcs/string'
require 'diff/lcs/hunk'

class BrowseController < ApplicationController

  prepend_before_filter :get_model_from_id_param, :except => [:index, :list_models, :search, :news, :one_node, :whats_new, :view_random_model, :about]
  before_filter :require_login, :only => [:revert_model, :set_permissions, :whats_new]

  before_filter :check_visibility_permissions, :only => [:one_model, :model_contents, :one_applet ]
  before_filter :check_changeability_permissions, :only => [:revert_model]

  def list_models
    @models = Node.paginate(:page => params[:page],
                            :order => 'name ASC',
                            :conditions => ["node_type_id = ? ", Node::MODEL_NODE_TYPE])
  end

  def one_node
    node = Node.find(params[:id])

    if node.is_model?
      redirect_to :action => :one_model, :id => params[:id]
    else
      send_data node.file_contents, :filename => node.name, :type => node.mime_type
    end
  end

  def display_preview
    if @model.latest_preview.blank?
      redirect_to "/images/no-preview.png"
    else
      send_data(@model.latest_preview, :type => 'image/png', :disposition => 'inline')
    end
  end

  def download_model
    # Create the zipfile
    Zip::ZipOutputStream::open(@model.zipfile_name_full_path) do |io|
      io.put_next_entry("#{@model.download_name}.nlogo")
      io.write(@model.file_contents)

      # Now we get all child nodes that are not themselves models.
      @model.non_models.each do |child|
        io.put_next_entry("#{child.filename}")
        io.write(child.file_contents)
      end
    end

    send_file(@model.zipfile_name_full_path,
              :filename => @model.zipfile_name,
              :type => 'application/zip',
              :disposition => "inline")
  end

  def model_contents
    send_data @model.file_contents
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
                         :node_contents => version.file_contents,
                         :note => "Reverted to older version")
    if @new_version.save
      flash[:notice] = "Model was reverted to an older version"
    else
      flash[:notice] = "Error reverting the model; nothing was changed."
    end

    redirect_to :back
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
      if read_permission.short_form == 'g' and @model.group.nil?
        read_permission = PermissionSetting.find_by_short_form('a')
      end

      write_permission = PermissionSetting.find_by_short_form(params[:write_permission])
      if write_permission.short_form == 'g' and @model.group.nil?
        write_permission = PermissionSetting.find_by_short_form('a')
      end

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
        :file_contents => nv.description}
    end

    @node.postings.find(:all, :conditions => ["created_at >= ? ", how_recent]).each do |posting|

      @new_things <<
        {:id => posting.id,
        :node_id => posting.node_id,
        :node_name => posting.node.name,
        :date => posting.created_at,
        :description => "Posting by '#{posting.person.fullname}' about the '#{posting.node.name}' model",
        :title => posting.title,
        :file_contents => posting.body}
    end

    @node.tagged_nodes.find(:all, :conditions => ["created_at >= ? ", how_recent]).each do |tn|

      @new_things <<
        {:id => tn.id,
        :node_id => tn.node_id,
        :node_name => tn.node.name,
        :date => tn.created_at,
        :description => "Model '#{tn.node.name}' tagged with '#{tn.tag.name}' by '#{tn.person.fullname}'",
        :title => "Model '#{tn.node.name}' tagged with '#{tn.tag.name}' by '#{tn.person.fullname}'",
        :file_contents => "<p>'#{tn.person.fullname} tagged the '#{tn.node.name}' model</p>"
      }
    end

    respond_to do |format|
      format.atom { @new_things }
    end
  end

  def view_random_model
    redirect_to :controller => :browse, :action => :one_model, :id => Node.models.rand.id
  end

  # Define methods for tabs
  ['preview', 'applet', 'info', 'procedures', 'download', 'discuss', 'history', 'tags',  'files',
   'related', 'upload', 'permissions'].each do |tab_name|
    define_method("browse_#{tab_name}_tab".to_sym) do
      render :layout => 'browse_tab'
    end
  end

  def rename_model
    if !@model.people.member?(@person)
      flash[:notice] = 'You are not allowed to rename this model.'
      redirect_to :controller => :browse, :action => :one_model, :id => params[:id]
      return
    end
  end

  def rename_model_action
    if params[:id].blank?
      flash[:notice] = 'No model ID provided'
      redirect_to :back
      return
    end

    if params[:new_name].blank?
      flash[:notice] = 'You must enter a new name for the model.'
      redirect_to :back
      return
    end

    @model.name = params[:new_name]
    @model.save!

    flash[:notice] = 'Success!'
    redirect_to :controller => :browse, :action => :one_model, :id => @model.id
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
