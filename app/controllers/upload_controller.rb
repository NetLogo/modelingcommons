class UploadController < ApplicationController

  before_filter :check_changeability_permissions, :only => [:update_model, :add_document]

  def new_model
  end

  def create_model
    # This method creates a new nlmodel, and its initial
    # nlmodel_version.  Each nlmodel has one or more nlmodel_versions
    # associated with it.  This allows us to keep track of versions on
    # a per-model basis, even though it's (unfortunately) more
    # complicated than I would like.

    # Integrity checks to add at some point:
    # (1) Does the filename match the model name?
    # (2) Is the model file seemingly intact?
    # (3) Did we get a preview PNG?
    # (4) Put the preview PNG in the filesystem, as ID.png, where ID is the
    #     model's ID

    model_name = params[:new_model][:name]

    # Make sure that a model doesn't already exist with this name.  If
    # it does, give an error message.
    if Nlmodel.find_by_name(model_name)
      flash[:notice] = "Sorry, but this model name ('#{model_name}') is already taken.  Please try a new one.  Alternatively, you may upload a new version of this model."
      redirect_to :back
      return
    end

    # Now do some sanity checking on the uploaded filenames
    new_model_filename =
      params[:new_model][:uploaded_body].original_filename
    if new_model_filename !~ /.nlogo$/
      flash[:notice] = "Sorry, but uploaded models must have a '.nlogo' suffix.  Please make sure that the model filename ends in '.nlogo'."
      redirect_to :back
      return
    end

    if not params[:new_model][:uploaded_preview].blank?
      preview_image_filename =
        params[:new_model][:uploaded_preview].original_filename
      if preview_image_filename !~ /.png$/
        flash[:notice] = "Sorry, but preview images must be in 'PNG' format.  Please make sure that the preview image filename ends in '.png'."
        redirect_to :back
        return
      end
    end

    # ------------------------------------------------------------
    # Create a new model, using the name and owner.
    # ------------------------------------------------------------
    @model = Nlmodel.new(:name => model_name,
                         :person_id => @person.id)
    if @model.save
      flash.now[:notice] = "Congratulations!  The model '#{@model.name}' was successfully uploaded.  "
    else
      flash.now[:notice] = "Error uploading the '#{@model.name}' model; please try again."
      redirect_to :back
      return
    end

    # Create a new model version, using the model and owner, as well
    # as the uploaded contents.
    @version =
      NlmodelVersion.create(:nlmodel_id => @model.id,
                            :person_id => @person.id,
                            :contents => params[:new_model][:uploaded_body].read,
                            :note => "Initial upload of model")
    @version.save!

    # ------------------------------------------------------------
    # Create preview file
    # ------------------------------------------------------------
    if not params[:new_model][:uploaded_preview].blank?
      preview_image = params[:new_model][:uploaded_preview].read
      params[:new_model].delete(:uploaded_preview)

      # Write the model preview file
      File.open(@model.preview_filename, 'w') do |file|
        file.puts preview_image
      end
    end

  end

  def update_model
    # Make sure that the user chose a fork method
    if params[:fork].blank?
      flash[:notice] = "Please select an action."
      redirect_to :back
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

        flash[:notice] << "Added new node ID '#{clone_child.id}', a cloned child to node #{existing_node.id}. "
        redirect_to :back
        return
      end
    end

    # Make sure that we are getting some inputs
    if params[:new_version].blank?
      logger.warn "Blank new_version -- returning"
      flash[:notice] = "new_version was not set in form -- try again?"
      redirect_to :back
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
      Notifications.deliver_modified_model(model_people, @version.nlmodel)
    end

    flash[:notice] << "Successfully saved a new version, overwriting the previous one."
    redirect_to :back

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
      redirect_to :back
    end
  end

end
