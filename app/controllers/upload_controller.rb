# Controller to handle uploads

class UploadController < ApplicationController

  before_filter :require_login
  before_filter :check_changeability_permissions, :only => [:update_model]

  def create_model
    if params[:new_model].blank? or params[:new_model][:name].blank?
      flash[:notice] = "Sorry, but you must enter a model name and file."
      redirect_to :action => :new_model
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
        flash[:notice] = "Error creating a new model object; it was not saved."
        redirect_to :back
      end

      # Create a new version for that node, and stick the contents in there
      node_version_contents = params[:new_model][:uploaded_body].read

      node_version_contents.gsub!(/[^\s\$#\@a-zA-Z0-9.!:?~`'"%^&*()\[\]{}\\|;+=,<>_\/-]/, "_")

      new_version =
        NodeVersion.new(:node_id => @model.id,
                        :person_id => @person.id,
                        :contents => node_version_contents,
                        :description => 'Initial upload')

      begin
        new_version.save!
        flash.now[:notice] = "Thanks for uploading the new model called '#{model_name}'."
      rescue Exception => e
        logger.warn "Exception message: '#{e.message}'"
        logger.warn "Exception backtrace: '#{e.backtrace.inspect}'"

        flash[:notice] = "Error creating a new model version; it was not saved."
        redirect_to :back
        raise ActiveRecord::Rollback, "Call tech support!"
      end

      # ------------------------------------------------------------
      # Preview image
      # ------------------------------------------------------------

      if params[:new_model][:uploaded_preview].present?

        # Create a preview
        attachment = NodeAttachment.new(:node_id => @model.id,
                                        :person_id => @person.id,
                                        :description => "Preview for '#{model_name}'",
                                        :filename => model_name + '.png',
                                        :type => 'preview',
                                        :contents => params[:new_model][:uploaded_preview].read)
        expire_page :action => :display_preview, :id => @model.id

        if !attachment.save
          flash[:notice] = "Error creating a new preview object; it was not saved."
          redirect_to :back
        end
      end

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

      @model.update_attributes(:visibility => read_permission,
                               :changeability => write_permission,
                               :group => group)
    end

  end

  def update_model
    # Get the node, and the fork method
    existing_node = Node.find(params[:new_version][:node_id])
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
      child_node = Node.create(:parent_id => existing_node.id,
                               :name => "Child of #{existing_node.name}")
      node_id = child_node.id
      flash[:notice] << "Added a new child to this model. "
    elsif fork == 'overwrite'
      node_id = existing_node.id
      flash[:notice] << "Added new version to node #{existing_node.id}. "
    end

    node_version_contents = params[:new_version][:uploaded_body].read
    node_version_contents.gsub!(/[^\s\$#\@a-zA-Z0-9.!:?~`'"%^&*()\[\]{}\\|;+=,<>_\/-]/, "_")

    # Create the new version for this node
    new_version =
      NodeVersion.new(:node_id => node_id,
                      :person_id => @person.id,
                      :contents => node_version_contents,
                      :description => description)

      begin
        new_version.save!
      rescue Exception => e
        logger.warn "Exception message: '#{e.message}'"
        logger.warn "Exception backtrace: '#{e.backtrace.inspect}'"

        flash[:notice] = "Error updating the model."
        redirect_to :back
        raise ActiveRecord::Rollback, "Call tech support!"
      end

    # Notifications.deliver_modified_model(new_version.node.people.reject { |p| p == @person}, new_version.node)

    redirect_to :back, :anchor => "upload-div"
  end


end
