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
      @model = Node.new(:node_type_id => Node::MODEL_NODE_TYPE,
                        :parent_id => nil,
                        :name => model_name)

      if !@model.save
        flash[:notice] = "Error creating a new model object; it was not saved."
        redirect_to :back
      end

      # Create a new version for that node, and stick the contents in there
      node_version_contents = params[:new_model][:uploaded_body].read

      new_version =
        NodeVersion.new(:node_id => @model.id,
                        :person_id => @person.id,
                        :file_contents => node_version_contents,
                        :description => 'Initial upload')

      if new_version.save
        flash[:notice] = "Thanks for uploading the new model called '#{model_name}'."
      else
        flash[:notice] = "Error creating a new model version; it was not saved."
        redirect_to :back
      end

      # ------------------------------------------------------------
      # Node and version for the preview image
      # ------------------------------------------------------------

      if params[:new_model][:uploaded_preview].present?

        # Create a new preview node, whose parent is the new model node
        preview_node = Node.new(:node_type_id => Node::PREVIEW_NODE_TYPE,
                                :parent_id => @model.id,
                                :name => model_name + ".png")

        if !preview_node.save
          flash[:notice] = "Error creating a new preview object; it was not saved."
          redirect_to :back
        end

        # Create a new version for the preview, and stick the contents in there
        preview_version =
          NodeVersion.new(:node_id => preview_node.id,
                          :person_id => @person.id,
                          :file_contents => params[:new_model][:uploaded_preview].read,
                          :description => 'Initial preview version')


        if preview_version.save
          flash[:notice] << "  The preview image was also saved."
        else
          flash[:notice] = "Error creating a new preview version; it was not saved."
          redirect_to :back
        end

      end

      # If we got a group and permission settings, set those as well
      group_id = params[:group_id].blank? ? nil : params[:group_id]
      group = Group.find(:first, :conditions => { :id => group_id })

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
    # Make sure that the user chose a fork method
    if params[:fork].blank?
      flash[:notice] = "Please select an action."
      redirect_to :back, :anchor => "upload-div"
      return
    end

    # Get the node, and the fork method
    existing_node = Node.find(params[:new_version][:node_id])
    fork = params[:fork]

    flash[:notice] = ''

    # Make sure that we are getting some inputs
    if params[:new_version].blank?
      logger.warn "Blank new_version -- returning"
      flash[:notice] = "new_version was not set in form -- try again?"
      redirect_to :back, :anchor => "upload-div"
    end

    # There are four possibilities:
    # (1) New version for this model
    # (2) New node and new version -- but the node's parent is this model
    # (3) New version and new model -- node's parent is null
    # (4) Don't upload anything -- just clone this model (taken care of above)

    # If fork is 'child' or 'newmodel', then we have to create a new
    # node, and then use that as the node_id to which the new version
    # is attached. If fork is 'clone', then create a copy of this
    # model, and connect the child to the parent.  Otherwise, we just
    # use node.id as the node ID.

    if fork == 'child'
      child_node = Node.create(:node_type_id => Node::MODEL_NODE_TYPE,
                               :parent_id => existing_node.id,
                               :name => "Child of #{existing_node.name}")
      node_id = child_node.id
      flash[:notice] << "Added a new child to this model. "
    elsif fork == 'newmodel'
      new_node = Node.create(:node_type_id => Node::MODEL_NODE_TYPE,
                             :parent_id => nil,
                             :name => params[:new_version][:description])
      node_id = new_node.id
      flash[:notice] << "Added new model (#{new_node.id}). "
    else
      node_id = existing_node.id
      flash[:notice] << "Added new version to node #{existing_node.id}. "
    end

    # Create the new version for this node
    new_version =
      NodeVersion.create(:node_id => node_id,
                         :person_id => @person.id,
                         :file_contents => params[:new_version][:uploaded_body].read,
                         :description => params[:new_version][:description])

    # Now send e-mail notification
    model_people = new_version.node.people
    model_people.delete_if {|p| p == @person}

    if not model_people.empty?
      Notifications.deliver_modified_model(model_people, new_version.node)
    end

    redirect_to :back, :anchor => "upload-div"
  end


end
