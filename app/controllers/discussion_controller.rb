class DiscussionController < ApplicationController

  before_filter :require_login, :only => [:new, :create, :delete]

  def new
    params[:new_posting][:person_id] = @person.id
    @posting = Posting.create(params[:new_posting])

    # Now send e-mail notification
    # discussion_people = @posting.nlmodel.postings.map { |p| p.person}
    # discussion_people << @posting.nlmodel.all_people
    # discussion_people = discussion_people.flatten.uniq

    # discussion_people.delete_if {|p| p == @person}

    # if not discussion_people.empty?
    # Notifications.deliver_updated_discussion(discussion_people, @posting.nlmodel)
    # end

    if @posting.save
      flash[:notice] = "Thanks for contributing to our discussion!"
    else
      flash[:notice] = "Error saving your posting.  Sorry!"
    end

    redirect_to :back, :anchor => "discuss"
  end

  def delete
    Posting.find(params[:id]).update_attributes(:deleted_at => Time.now)
    redirect_to :controller => :browse, :action => :one_model, :id => posting.node_id, :anchor => "discuss"
  end

  def undelete
    Posting.find(params[:id]).update_attributes(:deleted_at => nil)
    redirect_to :controller => :browse, :action => :one_model, :id => posting.node_id, :anchor => "discuss"
  end

  def create
    Posting.find(params[:id]).update_attributes(:deleted_at => Time.now)
  end

  def mark_as_answered
    Posting.find(params[:id]).update_attributes(:answered_at => Time.now)
    redirect_to :controller => :browse, :action => :one_model, :id => posting.node_id, :anchor => :discuss
  end

  def mark_as_unanswered
    Posting.find(params[:id]).update_attributes(:answered_at => nil)
    redirect_to :controller => :browse, :action => :one_model, :id => posting.node_id, :anchor => :discuss
  end

end
