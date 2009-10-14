class UploadController < ApplicationController

  before_filter :require_login
  prepend_before_filter :get_model_from_id_param, :only => [:add_document]
  before_filter :check_changeability_permissions, :only => [:update_model, :add_document]

  def new_model
  end

  def create_model
    model_name = params[:new_model][:name]

    Node.transaction do

      # Create a new node, without a parent
      logger.warn "[create_model] About to Node.create"
      @model = Node.create(:node_type_id => Node::MODEL_NODE_TYPE,
                           :parent_id => nil,
                           :name => model_name)

      # Create a new version for that node, and stick the contents in there
      logger.warn "[create_model] About to get uploaded body contents"
      node_version_contents = params[:new_model][:uploaded_body].read

      logger.warn "[create_model] node_version_contents = '#{node_version_contents}'"

      logger.warn "[create_model] About to NodeVersion.create"
      new_version =
        NodeVersion.create(:node_id => @model.id,
                           :person_id => @person.id,
                           :file_contents => node_version_contents,
                           :description => 'Initial upload')

      # If we got a preview, then create a node and version for it
      logger.warn "[create_model] About to check for an uploaded preview"
      if params[:new_model][:uploaded_preview].present?

        # Create a new preview node, whose parent is the new model node
        logger.warn "[create_model] About to Node.create (preview)"
        preview_node = Node.create(:node_type_id => Node::PREVIEW_NODE_TYPE,
                                   :parent_id => @model.id,
                                   :name => model_name + ".png")

        # Create a new version for the preview, and stick the contents in there
        logger.warn "[create_model] About to NodeVersion.create (preview)"
        preview_version =
          NodeVersion.create(:node_id => preview_node.id,
                             :person_id => @person.id,
                             :file_contents => params[:new_model][:uploaded_preview].read,
                             :description => 'Initial preview version')
      else
        logger.warn "[create_model] No uploaded preview"
      end

      # If we got a group and permission settings, set those as well
      logger.warn "[create_model] About to get permissions"
      read_permission = PermissionSetting.find_by_short_form(params[:read_permission])
      write_permission = PermissionSetting.find_by_short_form(params[:write_permission])

      logger.warn "[create_model] About to set permissions"
      @model.visibility_id = read_permission.id
      @model.changeability_id = write_permission.id

      logger.warn "[create_model] About to set group"
      if params[:group] and params[:group][:id]
        successfully_set_group = @model.update_attributes(:group_id => params[:group][:id])

        logger.warn "[create_model] successfully_set_group = '#{successfully_set_group}'"
      end

      logger.warn "[create_model] About to save model"
      @model.save!
    end

    flash[:notice] = "Thanks for uploading the new model called '#{model_name}'."
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

    # If we're cloning, then there's no need to look for any uploaded document.
    if fork == 'clone'
      Node.transaction do
        clone_child = Node.create(:node_type_id => Node::MODEL_NODE_TYPE,
                                  :parent_id => existing_node.id,
                                  :name => "Cloned child of #{existing_node.name}")
        clone_child.reload
        logger.warn "ID of new clone_child is '#{clone_child.id}'"

        # Iterate through each version of the parent node
        existing_node.node_versions.each do |existing_version|
          nv = existing_version.dup
          nv.id = nil
          nv.node_id = clone_child.id
          nv.save!
          nv.reload
          logger.warn "new version ID '#{nv.id}' created"
        end

        # Iterate through each child of the parent node
        existing_node.children.each do |existing_child|
          logger.warn "iterating through existing_node.children: existing_child = #{existing_child.id}"

          # Ignore the just-created clone child
          if existing_child == clone_child
            logger.warn "existing_child = clone_child; next!"
            next
          end

          logger.warn "creating new node"
          n = Node.create(:node_type_id => existing_child.node_type_id,
                          :parent_id => clone_child.id,
                          :name => existing_child.name)
          n.save!
          n.reload
          logger.warn "new node ID '#{n.id}' created"

          existing_child.node_versions.each do |existing_version|
            logger.warn "iterating through existing_child.node_versions: existing_version == #{existing_version.id}"

            nv = existing_version.dup
            nv.id = nil
            nv.node_id = n.id
            nv.save!
            nv.reload
            logger.warn "new version ID '#{nv.id}' created"

          end
        end

        existing_node.updated_at = Time.now
        existing_node.save!

        flash[:notice] << "Added new node ID '#{clone_child.id}', a cloned child to node #{existing_node.id}. "
        redirect_to :back, :anchor => "upload-div"
        return
      end
    end

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

    flash[:notice] << "Successfully saved a new version."
    redirect_to :back, :anchor => "upload-div"
  end


  # Add a document
  def add_document
    description = params[:description]
    node_type_id = params[:document][:node_type_id].to_i
    filename = params[:uploaded_file].original_filename
    logger.warn "[add_document] Model is '#{@model.name}', ID '#{@model.id}'"

    # If we have a preview image, then change the name to be the same as the model.  Otherwise,
    # we'll go a bit crazy.
    if node_type_id == Node::PREVIEW_NODE_TYPE
      logger.warn "[add_document] Uploading a preview -- setting the name"
      filename = @model.name + '.png'
      logger.warn "[add_document] Filename is now '#{filename}'"
    else
      logger.warn "[add_document] Keeping filename as '#{filename}'"
    end

    logger.warn "[add_document] About to start Node.transaction"
    Node.transaction do

      # Grab this node if it exists, or create it if it doesn't
      logger.warn "[add_document] Looking to see if there is already a node of type '#{node_type_id}' named '#{filename}'"
      node = Node.find(:first,
                       :conditions => ["parent_id = ? and name = ? and node_type_id = ?",
                                       @model.id, filename, node_type_id])

      if node.nil?
        logger.warn "[add_document] Nope, it's new -- creating a new node version"
        node = Node.create(:node_type_id => node_type_id,
                           :parent_id => @model.id,
                           :name => filename)
      end

      # Now we have a node (and node ID).  So we can create a new version!
      logger.warn "[add_document] Now creating a new node_version for node '#{node.id}'"
      new_node_version = NodeVersion.new(:node_id => node.id,
                                         :person_id => @person.id,
                                         :file_contents => params[:uploaded_file].read,
                                         :description => description)
      if new_node_version.save
        logger.warn "[add_document] Saved the node_version, ID '#{new_node_version.id}'.  Woo-hoo!"
        flash[:notice] = "Successfully added file, as node '#{new_node_version.id}'"
      else
        logger.warn "[add_document] Error saving the node_version.  Rats!"
        flash[:notice] = "Error adding file"
      end
      redirect_to :controller => :browse, :action => :one_model, :id => @model.id, :anchor => "files"
    end

    logger.warn "[add_document] Ended Node.transaction"
  end

end
