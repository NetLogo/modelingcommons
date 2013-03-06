# Controller that handles discussions

class DiscussionController < ApplicationController

  before_filter :require_login, :only => [:new, :create, :delete]
  before_filter :get_posting_id, :only => [:delete, :undelete, :mark_as_answered, :mark_as_unanswered]

  def create
    params[:new_posting][:person_id] = @person.id
    params[:new_posting][:title] ||= '(No title)'

    params[:new_posting][:body].gsub!('<', '&lt;')
    params[:new_posting][:body].gsub!('>', '&rt;')

    if params[:new_posting][:is_question].blank?
      params[:new_posting][:is_question] = false 
    end

    @posting = Posting.new(params[:new_posting])

    if @posting.save
      respond_to do |format|
        format.html do
          flash[:notice] = "Thanks for contributing to our discussion!" 
          redirect_to :back, :anchor => "discussion"
        end
        format.json do 
          @res = {:success => true, :message => 'Comment Added', :html => render_to_string(:partial => 'one_posting.html', :locals => { :posting => @posting})}
          render :json => @res
        end
      end
    else
      respond_to do |format|
        format.html do
          flash[:notice] = "Thanks for contributing to our discussion!" 
          redirect_to :back, :anchor => "discussion"
        end
        format.json do 
          @res = {:sucess => false, :message => 'Error adding comment'}
          render :json => @res
        end
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
