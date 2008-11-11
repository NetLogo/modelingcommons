class UploadController < ApplicationController

  before_filter :check_changeability_permissions, :only => [:update_model, :add_document]

  def new_model
  end

  def create_model
    model_name = params[:new_model][:name]

    # Create a new node, without a parent
    Node.transaction do
      new_model_node = Node.create(:node_type_id => 1,
                                   :parent_id => nil,
                                   :name => model_name)
      new_model_node.reload

      @model = new_model_node

      # Create a new version for that node, and stick the contents in there
      new_version =
        NodeVersion.create(:node_id => new_model_node.id,
                           :person_id => @person.id,
                           :contents => params[:new_model][:uploaded_body].read,
                           :description => 'Initial upload')
      new_version.reload

      # If we got a preview, then create a node and version for it
      if not params[:new_model][:uploaded_preview].blank?

        # Create a new preview node, whose parent is the new model node
        preview_node = Node.create(:node_type_id => 2,
                                   :parent_id => new_model_node.id,
                                   :name => "Preview image for #{model_name}")

        preview_node.reload

        # Create a new version for the preview, and stick the contents in there
        preview_version =
          NodeVersion.create(:node_id => preview_node.id,
                             :person_id => @person.id,
                             :contents => params[:new_model][:uploaded_preview].read,
                             :description => 'Initial preview version')
        new_version.reload
      end
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
        clone_child = Node.create(:node_type_id => 1,
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
      child_node = Node.create(:node_type_id => 1,
                               :parent_id => existing_node.id,
                               :name => "Child of #{existing_node.name}")
      node_id = child_node.id
      flash[:notice] << "Added new node (#{child_node.id}), a child to node #{existing_node.id}. "
    elsif fork == 'newmodel'
      new_node = Node.create(:node_type_id => 1,
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
                         :contents => params[:new_version][:uploaded_body].read,
                         :description => params[:new_version][:description])

    # Now send e-mail notification
    model_people = new_version.node.people
    model_people.delete_if {|p| p == @person}

    if not model_people.empty?
      Notifications.deliver_modified_model(model_people, new_version.node)
    end

    flash[:notice] << "Successfully saved a new version, overwriting the previous one."
    redirect_to :back, :anchor => "upload-div"

  end



  # Add a document
  def add_document
    parent_node_id = params[:new_document][:parent_node_id]
    description = params[:new_document][:description]
    node_type_id = params[:new_document][:node_type]
    filename = params[:new_document][:uploaded_document].original_filename

    Node.transaction do

      # Grab this node if it exists, or create it if it doesn't
      node = Node.find(:first,
                       :conditions => ["parent_id = ? and name = ? and node_type_id = ?",
                                       parent_node_id, filename, node_type_id])

      if node.nil?
        node = Node.create(:node_type_id => node_type_id,
                           :parent_id => parent_node_id,
                           :name => filename)
      end

      # Now we have a node (and node ID).  So we can create a new version!
      NodeVersion.create(:node_id => node.id,
                         :person_id => @person.id,
                         :contents => params[:new_document][:uploaded_document].read,
                         :description => description)

      flash[:notice] = "Successfully added file!"
      redirect_to :back, :anchor => "upload-div"
    end
  end

end
