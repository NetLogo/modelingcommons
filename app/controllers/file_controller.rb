# Controller that deals with creating files

class FileController < ApplicationController

  prepend_before_filter :get_model_from_id_param
  before_filter :check_changeability_permissions, :only => [:create, :delete]

  def create
    description = params[:description]
    attachment_type = params[:document][:type]
    filename = params[:uploaded_file].original_filename
    logger.warn "[create] Model is '#{@model.inspect}'"

    filename = @model.name + '.png' if attachment_type == 'preview'

    # Add a new attachment
    if NodeAttachment.create(:node_id => @model.id,
                             :person_id => @person.id,
                             :description => description,
                             :filename => filename,
                             :type => attachment_type,
                             :contents => params[:uploaded_file].read)
      flash[:notice] = "Successfully added file '#{filename}'."
    else
      flash[:notice] = "Error adding file '#{filename}'."
    end

    redirect_to :controller => :browse, :action => :one_model, :id => @model.id, :anchor => "files"
  end

  def delete
    # Remove the attachment
    NodeAttachment.destroy(params[:file_id])
    flash[:notice] = "Removed the file."
    redirect_to :controller => :browse, :action => :one_model, :id => @model.id, :anchor => "files"
  end

end
