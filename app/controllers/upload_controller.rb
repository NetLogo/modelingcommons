# Controller to handle uploads

class UploadController < ApplicationController

  before_filter :require_login

  def create_model
    
    if params[:new_model].blank? or params[:new_model][:name].blank? or params[:new_model][:uploaded_body].blank?
      respond_to do |format|
        format.html do 
          flash[:notice] = "Sorry, but you must enter a model name and file."
          redirect_to :action => :new_model
        end
        format.json do
          render :json => {:status => 'MISSING_PARAMETERS'}
        end
      end
      
      return
    end

    model_name = params[:new_model][:name]

    Node.transaction do

      # ------------------------------------------------------------
      # Node and version for the model
      # ------------------------------------------------------------

      # Create a new node, without a parent
      @model = Node.new(:parent_id => nil,
                        :name => model_name)

      if !@model.save
        respond_to do |format|
          format.html do 
            logger.warn "Error(s): @model.errors"
            flash[:notice] = "Error creating a new model object; it was not saved."
            redirect_to :back
          end
          format.json do 
            render :json => {:status => 'MODEL_NOT_SAVED'}
          end
        end
        return
      end

      # Create a new version for that node, and stick the contents in there
      
      params[:new_model][:uploaded_body].rewind
      node_version_contents = params[:new_model][:uploaded_body].read

      new_version =
        Version.new(:node_id => @model.id,
                    :person_id => @person.id,
                    :contents => node_version_contents,
                    :description => 'Initial upload')
      
      begin
        new_version.save!
        flash[:notice] = "Thanks for uploading the new model called '#{model_name}'."
        
        # If we got a group and permission settings, set those as well
        group_id = params[:group_id].blank? ? nil : params[:group_id]
        group = Group.group_or_nil(group_id)
        
        read_permission = PermissionSetting.find_by_short_form(params[:read_permission])
        if group.nil? and read_permission and read_permission.is_group?
          read_permission = PermissionSetting.find_by_short_form('u')
        end
        
        write_permission = PermissionSetting.find_by_short_form(params[:write_permission])
        if group.nil? and write_permission and write_permission.is_group?
          write_permission = PermissionSetting.find_by_short_form('u')
        end
        
        @model.update_attributes!(:visibility => read_permission,
                                  :changeability => write_permission,
                                  :group => group)
        
        # ------------------------------------------------------------
        # Preview image
        # ------------------------------------------------------------
        
        params[:new_model][:uploaded_preview].rewind
        preview_body = params[:new_model][:uploaded_preview].read

        if preview_body.present?
          
          # Create a preview
          params[:new_model][:uploaded_preview].rewind
          attachment = Attachment.new(:node_id => @model.id,
                                      :person_id => @person.id,
                                      :description => "Preview for '#{model_name}'",
                                      :filename => model_name + '.png',
                                      :content_type => 'preview',
                                      :contents => preview_body)
          
          expire_page :action => :display_preview, :id => @model.id
          
          if !attachment.save
            response[:status] = 'SUCCESS_PREVIEW_NOT_SAVED'
            flash[:notice] = "Error creating a new preview object; it was not saved."
          end
        end

        Notifications.deliver_upload_acknowledgement(@model, @person)

        respond_to do |format|
          format.html do 
            redirect_to :controller => :browse, :action => :one_model, :id => @model.id
          end
          format.json do 
            render :json => {:status => 'SUCCESS', :model => {:id => @model.id, :name => model_name, :url => url_for(:controller => :browse, :action => :one_model, :id => @model.id)}}
          end
        end
        
      rescue Exception => e
        logger.warn "Exception class: '#{e.class}'"
        logger.warn "Exception message: '#{e.message}'"
        logger.warn "Exception backtrace: '#{e.backtrace.join("\n")}'"

        respond_to do |format|
          format.html do 
            flash[:notice] = "Error creating a new model version; it was not saved."
            redirect_to :back
          end
          format.json do 
            render :json => {:status => 'MODEL_NOT_SAVED'}
          end
        end
        
        raise ActiveRecord::Rollback, "Call tech support!"
      end
    end
  end

  def update_model
    existing_node = Node.find(params[:new_version][:node_id])
    
    if params[:new_version].blank? or params[:new_version][:description].blank? or params[:new_version][:uploaded_body].blank?
      respond_to do |format|
        format.html do 
          flash[:notice] = "Sorry, but you must enter a model name, file, and description."
          redirect_to :controller => :browse, :action => :one_model, :id => existing_node.id
        end
        format.json do 
          render :json => {:status => 'MISSING_PARAMETERS'}
        end
      end
      
      return
    end

    fork = params[:fork] || 'overwrite'

    description = params[:new_version][:description]
    description = 'No description provided' if description.blank?

    flash[:notice] = ''

    # If fork is 'child', then we have create a new node, and then
    # set its parent to the current node.  Then we create a new node_version
    # attached to this new (child) node.

    # If fork is 'overwrite', then we create a new node_version,
    # attached to the existing node.

    if fork == 'child'
      name_of_new_child = params[:new_version][:name_of_new_child]
      name_of_new_child = "Child of #{existing_node.name}" if name_of_new_child.blank?

      child_node = Node.create(:parent_id => existing_node.id,
                               :name => name_of_new_child,
                               :group_id => existing_node.group_id,
                               :visibility_id => existing_node.visibility_id,
                               :changeability_id => existing_node.changeability_id)

      node_id = child_node.id
      flash[:notice] << "Added a new child to this model. "
    elsif fork == 'overwrite'

      return unless check_changeability_permissions
      node_id = existing_node.id
      flash[:notice] << "Added new version to node #{existing_node.id}. "
    else
      raise "Unknown option '#{fork}' passed to update_model"
    end

    node_version_contents = params[:new_version][:uploaded_body].read

    # Create the new version for this node
    new_version =
      Version.new(:node_id => node_id,
                  :person_id => @person.id,
                  :contents => node_version_contents,
                  :description => description)

    begin
      new_version.save!
    rescue Exception => e
      #Error saving
      
      logger.warn "Exception message: '#{e.message}'"
      logger.warn "Exception backtrace: '#{e.backtrace.inspect}'"

      respond_to do |format|
        format.html do 
          flash[:notice] = "Error updating the model."
          redirect_to :back
        end
        format.json do 
          render :json => {:status => 'MODEL_NOT_SAVED'}
        end
      end
      
      raise ActiveRecord::Rollback, "Call tech support!"
      return
    end

    respond_to do |format|
      format.html do 
        redirect_to :back, :anchor => "upload-div"
      end
      format.json do 
        render :json => response = {:status => 'SUCCESS', :type => fork, :model => {:id => node_id, :name => new_version.node.name, :url => url_for(:controller => :browse, :action => :one_model, :id => node_id)}}
      end
    end
  end


  def destroy
    @model = Node.find(params[:id])

    if @model.author?(@person)

      @model.attachments.each do |attachment|
        attachment.destroy
      end

      @model.node_versions.each do |nv|
        nv.destroy
      end

      @model.tagged_nodes.each do |tn|
        tn.destroy
      end

      @model.postings.each do |posting|
        posting.destroy
      end

      @model.recommendations.each do |recommendation|
        recommendation.destroy
      end

      @model.destroy

      flash[:notice] = "Model '#{@model.name}' has been deleted."
    else
      flash[:notice] = "You don't have permission to delete '#{@model.name}'."
    end

    redirect_to :controller => :account, :action => :mypage
  end

end
