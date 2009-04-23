class FileController < ApplicationController
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
    redirect_to :controller => :browse, :action => :one_model, :id => model_id, :anchor => "ui-tabs-31"
  end

end
