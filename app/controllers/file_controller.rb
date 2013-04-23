# Controller that deals with creating files

class FileController < ApplicationController

  prepend_before_filter :get_model_from_id_param
  before_filter :check_changeability_permissions, :only => [:create, :delete]

  def create
    description = params[:description]
    attachment_type = params[:document][:type]
    filename = params[:uploaded_file].original_filename
    params[:uploaded_file].rewind
    contents = params[:uploaded_file].read
    logger.warn "[create] Model is '#{@model.inspect}'"
    filename = @model.name + '.png' if attachment_type == 'preview'

    params[:uploaded_file].rewind
    contents = params[:uploaded_file].read

    # Add a new attachment, if allowed
    if not @model.changeable_by_user?(@person)
      flash[:notice] = "You are not allowed to modify this model."

    elsif Attachment.create!(:node_id => @model.id,
                             :person_id => @person.id,
                             :description => description,
                             :filename => filename,
                             :content_type => attachment_type,
                             :contents => contents)
      flash[:notice] = "Successfully added file '#{filename}'."
    else
      flash[:notice] = "Error adding file '#{filename}'."
    end

    redirect_to :controller => :browse, :action => :one_model, :id => @model.id, :anchor => "files"
  end

  def delete
    if not @model.changeable_by_user?(@person)
      flash[:notice] = "You are not allowed to remove files from this model."
      logger.warn "User '#{@person.inspect}' tried to remove a file, but was prevented from doing so."
    elsif attachment = Attachment.find(params[:file_id])
      attachment.destroy
      flash[:notice] = "Removed the file."
    else
      flash[:notice] = 'No such file to remove.'
    end

    redirect_to :controller => :browse, :action => :one_model, :id => @model.id, :anchor => "files"
  end

end
