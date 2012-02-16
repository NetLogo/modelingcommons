# Controller that handles browsing through models

class BrowseController < ApplicationController

  caches_page :display_preview

  prepend_before_filter :log_one_action, :except => [:display_preview]
  prepend_before_filter :get_model_from_id_param, :except => [:index, :list_models, :list_recent_models, :search, :news, :one_node, :view_random_model, :about, :model_contents, :extension]

  before_filter :require_login, :only => [:set_permissions]
  before_filter :check_visibility_permissions, :only => [:one_model, :one_applet ]

  def list_models
    logger.warn "[BrowseController#list_models] #{Time.now} before getting @models"
    @models = Node.all(:order => "name ASC", :include => [:tags, :visibility, :changeability])
    logger.warn "[BrowseController#list_models] #{Time.now} before filtering @models"
    @models = @models.select {|model| model.visible_to_user?(@person)}
    logger.warn "[BrowseController#list_models] #{Time.now} after filtering @models"
    render :layout => 'application_nomargin'
  end


  def list_recent_models
    @models = Node.all(:order => "updated_at DESC", :limit => 100).select {|model| model.visible_to_user?(@person)}[0..19]
    render 'list_models' , :layout => 'application_nomargin'
  end

  def one_model
    render :layout => 'application_nomargin'
  end

  def one_node
    redirect_to :action => :one_model, :id => params[:id]
  end

  def display_preview
    if @model.preview.blank?
      expires_in 5.minutes
      redirect_to "/images/1x1.png"
    else
      expires_in 12.hours
      render :text => @model.preview.contents, :type => 'image/png', :disposition => 'inline', :layout => false
    end
  end

  def download_model
    send_file(@model.create_zipfile, :filename => @model.zipfile_name, :type => 'application/zip', :disposition => "inline")
  end

  def model_contents
    if params[:id].present?
      @model = Node.find(params[:id]) if params[:id].present?
      send_data @model.contents
    else
      logger.warn "[BrowseController#model_contents] Error requesting contents of model ID '#{params[:id]}'"
      render :text => "Error sending contents of model ID '#{params[:id]}'"
    end
  end

  def set_permissions
    if params[:read_permission].blank? or params[:write_permission].blank?
      #flash[:notice] = 'Both read and write permissions must be specified.'
      @set_permission_result = {:message => 'Both read and write permissions must be specified.' } 
    elsif (params[:read_permission] == 'g' or params[:write_permission] == 'g') and params[:group_id].blank?
      #flash[:notice] = 'You can only set group permissions if you also set a group.'
      @set_permission_result = {:message => 'You can only set group permissions if you also set a group.' } 
    else
      @model.update_attributes(:visibility => PermissionSetting.find_by_short_form(params[:read_permission]),
                               :changeability => PermissionSetting.find_by_short_form(params[:write_permission]),
                               :group_id => params[:group_id])
      @set_permission_result = {:message => "Successfully set permissions" }
    end
    render :json => @set_permission_result
  end

  def follow
    @new_things = [ ]
    how_recent = 2.weeks.ago

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

  def extension
    send_file "#{RAILS_ROOT}/public/extensions/#{params[:dirname]}/#{params[:extensionname]}.#{params[:format]}"
  end
  
  
end
