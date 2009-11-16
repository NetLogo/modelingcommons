class FileController < ApplicationController

  prepend_before_filter :get_model_from_id_param
  before_filter :check_changeability_permissions, :only => [:create]

  def create
    description = params[:description]
    node_type_id = params[:document][:node_type_id].to_i
    filename = params[:uploaded_file].original_filename
    logger.warn "[create] Model is '#{@model.name}', ID '#{@model.id}'"

    # If we have a preview image, then change the name to be the same as the model.  Otherwise,
    # we'll go a bit crazy.
    if node_type_id == Node::PREVIEW_NODE_TYPE
      logger.warn "[create] Uploading a preview -- setting the name"
      filename = @model.name + '.png'
      logger.warn "[create] Filename is now '#{filename}'"
    else
      logger.warn "[create] Keeping filename as '#{filename}'"
    end

    logger.warn "[create] About to start Node.transaction"
    Node.transaction do

      # Grab this node if it exists, or create it if it doesn't
      logger.warn "[create] Looking to see if there is already a node of type '#{node_type_id}' named '#{filename}'"
      node = Node.find(:first,
                       :conditions => ["parent_id = ? and name = ? and node_type_id = ?",
                                       @model.id, filename, node_type_id])

      if node.nil?
        logger.warn "[create] Nope, it's new -- creating a new node version"
        node = Node.create(:node_type_id => node_type_id,
                           :parent_id => @model.id,
                           :name => filename)
      end

      # Now we have a node (and node ID).  So we can create a new version!
      logger.warn "[create] Now creating a new node_version for node '#{node.id}'"
      new_node_version = NodeVersion.new(:node_id => node.id,
                                         :person_id => @person.id,
                                         :file_contents => params[:uploaded_file].read,
                                         :description => description)
      if new_node_version.save
        logger.warn "[create] Saved the node_version, ID '#{new_node_version.id}'.  Woo-hoo!"
        flash[:notice] = "Successfully added file, as node '#{new_node_version.id}'"
      else
        logger.warn "[create] Error saving the node_version.  Rats!"
        flash[:notice] = "Error adding file"
      end
      redirect_to :controller => :browse, :action => :one_model, :id => @model.id, :anchor => "files"
    end

    logger.warn "[create] Ended Node.transaction"
  end



  def delete
    # Remove node versions
    file_node = Node.find(params[:id])
    model_id = file_node.parent_id

    file_node.node_versions.each do |nv|
      NodeVersion.destroy(nv.id)
    end

    # Now destroy the node itself
    Node.destroy(file_node.id)

    flash[:notice] = "Removed the file."
    redirect_to :controller => :browse, :action => :one_model, :id => model_id, :anchor => "files"
  end

end
