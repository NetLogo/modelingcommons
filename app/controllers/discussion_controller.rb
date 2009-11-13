class DiscussionController < ApplicationController

  before_filter :require_login, :only => [:new, :create, :delete]

  def create
    params[:new_posting][:person_id] = @person.id
    @posting = Posting.create(params[:new_posting])

    if @posting.save
      flash[:notice] = "Thanks for contributing to our discussion!"
    else
      flash[:notice] = "Error saving your posting.  Sorry!"
    end

    redirect_to :back, :anchor => "discuss"
  end

  def delete
    posting = Posting.find(params[:id])
    posting.update_attributes(:deleted_at => Time.now)
    flash[:notice] = "Posting deleted"
    redirect_to :controller => :browse, :action => :one_model, :id => posting.node_id, :anchor => "discuss"
  end

  def undelete
    posting = Posting.find(params[:id])
    posting.update_attributes(:deleted_at => nil)
    flash[:notice] = "Posting undeleted"
    redirect_to :controller => :browse, :action => :one_model, :id => posting.node_id, :anchor => "discuss"
  end

  def mark_as_answered
    posting = Posting.find(params[:id])
    posting.update_attributes(:answered_at => Time.now)
    redirect_to :controller => :browse, :action => :one_model, :id => posting.node_id, :anchor => :discuss
  end

  def mark_as_unanswered
    posting = Posting.find(params[:id])
    posting.update_attributes(:answered_at => nil)
    redirect_to :controller => :browse, :action => :one_model, :id => posting.node_id, :anchor => :discuss
  end

end
