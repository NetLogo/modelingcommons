# Controller that handles browsing through models

class BrowseController < ApplicationController

  prepend_before_filter :log_one_action, :except => [:display_preview]
  prepend_before_filter :get_model_from_id_param, :except => [:index, :list_models, :search, :news, :one_node, :view_random_model, :about]

  before_filter :require_login, :only => [:set_permissions]
  before_filter :check_visibility_permissions, :only => [:one_model, :model_contents, :one_applet ]

  def list_models
    @models = Node.all
  end

  def one_model
  end

  def one_node
    redirect_to :action => :one_model, :id => params[:id]
  end

  def display_preview
    if @model.preview.blank?
      send_file("#{RAILS_ROOT}/public/images/1x1.png",
                :type => 'image/png',
                :disposition => 'inline')
    else
      send_data(@model.preview.contents.to_s, :type => 'image/png', :disposition => 'inline')
    end
  end

  def download_model
    send_file(@model.create_zipfile, :filename => @model.zipfile_name, :type => 'application/zip', :disposition => "inline")
  end

  def model_contents
    send_data @model.contents
  end

  def one_applet
  end

  def set_permissions
    if params[:read_permission].blank? or params[:write_permission].blank?
      flash[:notice] = 'Both read and write permissions must be specified.'
    elsif (params[:read_permission] == 'g' or params[:write_permission] == 'g') and params[:group_id].blank?
      flash[:notice] = 'You can only set group permissions if you also set a group.'
    else
      @model.update_attributes(:visibility => PermissionSetting.find_by_short_form(params[:read_permission]),
                               :changeability => PermissionSetting.find_by_short_form(params[:write_permission]),
                               :group => Group.group_or_nil(params[:group_id]))
      flash[:notice] = 'Successfully set permissions.'
    end
  end

  def follow
    @new_things = [ ]
    how_recent = 6.months.ago

    @new_things +=
      @node.node_versions.select { |node_version| node_version.created_at >= how_recent }.map{ |node_version| node_version.new_thing }
    @new_things +=
      @node.postings.select { |posting| posting.created_at >= how_recent }.map{ |posting| posting.new_thing }
    @new_things +=
      @node.tagged_nodes.select { |tagged_node| tagged_node.created_at >= how_recent }.map{ |tagged_node| tagged_node.new_thing }

    respond_to do |format|
      format.atom { @new_things }
    end
  end

  def view_random_model
    models = Node.all.select {|model| model.visible_to_user?(@person)}

    if models.empty?
      flash[:notice] = 'Sorry, but you do not have permission to see any models.'
      redirect_to :controller => :account, :action => :login
    end

    redirect_to :controller => :browse, :action => :one_model, :id => models.rand.id
  end

  # Define methods for tabs
  ['preview', 'applet', 'info', 'procedures', 'discuss', 'files', 'history', 'tags',
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
    if params[:new_name].blank?
      flash[:notice] = 'You must enter a new name for the model.'
      redirect_to :back
      return
    end

    @model.update_attributes(:name => params[:new_name])
    flash[:notice] = "Successfully renamed the model to '#{@model.name}'."

    redirect_to :controller => :browse, :action => :one_model, :id => @model.id
  end
end
