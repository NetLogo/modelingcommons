# Controller that handles discussions

class DiscussionController < ApplicationController

  before_filter :require_login, :only => [:new, :create, :delete]
  before_filter :get_posting_id, :only => [:delete, :undelete, :mark_as_answered, :mark_as_unanswered]

  def create
    params[:new_posting][:person_id] = @person.id
    params[:new_posting][:title] ||= '(No title)'

    @posting = Posting.new(params[:new_posting])

    if @posting.save
      respond_to do |format|
        format.html do
          flash[:notice] = "Thanks for contributing to our discussion!" 
          redirect_to :back, :anchor => "discussion"
        end
        format.js 
      end
    else
      respond_to do |format|
        format.html do
          flash[:notice] = "Thanks for contributing to our discussion!" 
          redirect_to :back, :anchor => "discussion"
        end
        format.js { render :json => "Error" }
      end
    end      

  end

  def get_posting_id
    @posting = Posting.find(params[:id])
  end

  def delete
    @posting.update_attributes(:deleted_at => Time.now)
    flash[:notice] = "Posting deleted"
    redirect_to :controller => :browse, :action => :one_model, :id => @posting.node_id, :anchor => "discuss"
  end

  def undelete
    @posting.update_attributes(:deleted_at => nil)
    flash[:notice] = "Posting undeleted"
    redirect_to :controller => :browse, :action => :one_model, :id => @posting.node_id, :anchor => "discuss"
  end

  def mark_as_answered
    @posting.update_attributes(:answered_at => Time.now)
    flash[:notice] = "Question marked as answered"
    redirect_to :controller => :browse, :action => :one_model, :id => @posting.node_id, :anchor => :discuss
  end

  def mark_as_unanswered
    @posting.update_attributes(:answered_at => nil)
    flash[:notice] = "Question marked as unanswered"
    redirect_to :controller => :browse, :action => :one_model, :id => @posting.node_id, :anchor => :discuss
  end

end
