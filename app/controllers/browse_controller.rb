# Controller that handles browsing through models

class BrowseController < ApplicationController

  prepend_before_filter :get_model_from_id_param, :except => [:index, :list_models, :search, :news, :one_node, :view_random_model, :about]
  before_filter :require_login, :only => [:set_permissions]

  before_filter :check_visibility_permissions, :only => [:one_model, :model_contents, :one_applet ]

  def list_models
    @models = Node.find(:all, :order => 'name ASC')
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
    # Create the zipfile
    Zip::ZipOutputStream::open(@model.zipfile_name_full_path) do |io|
      io.put_next_entry("#{@model.download_name}.nlogo")
      io.write(@model.contents.to_s)

      # Now we get all child nodes that are not themselves models.
      @model.attachments.each do |attachment|
        io.put_next_entry("#{attachment.filename}")
        io.write(attachment.contents.to_s)
      end
    end

    send_file(@model.zipfile_name_full_path,
              :filename => @model.zipfile_name,
              :type => 'application/zip',
              :disposition => "inline")
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
      group = Group.find(:first, params[:group_id])
      @model.update_attributes(:visibility => PermissionSetting.find_by_short_form(params[:read_permission]),
                               :changeability => PermissionSetting.find_by_short_form(params[:write_permission]),
                               :group => group)
      flash[:notice] = 'Successfully set permissions.'
    end
  end

  def follow
    @new_things = [ ]
    how_recent = 6.months.ago

    @new_things += @node.node_versions.select { |nv| nv.created_at >= how_recent }.map{ |nv| nv.new_thing }
    @new_things += @node.postings.select { |p| p.created_at >= how_recent }.map{ |p| p.new_thing }
    @new_things += @node.tagged_nodes.select { |tn| tn.created_at >= how_recent }.map{ |tn| tn.new_thing }

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
