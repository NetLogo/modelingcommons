# Controller to deal with collaborations

class CollaborationsController < ApplicationController

  before_filter :require_login

  def create
    @node = Node.find(params[:node_id])
    if @node.author?(@person)
      @collaborator = Person.first(params[:collaborator_id])

      if @collaborator.nil?
        flash[:notice] = "Sorry, but I cannot find a person with ID '#{params[:collaborator_id]}'"
      elsif @collaborator == @person
        flash[:notice] = "You cannot add yourself as a collaborator."
      elsif @node.author?(@collaborator)
        flash[:notice] = "#{fullname} is already listed as an author."
      else
        @collaboration = Collaboration.new(:person => @collaborator,
                                           :node => @node)
        if @collaboration.save
          flash[:notice] = "Added #{fullname} a collaborator."
        else
          flash[:notice] = "Error adding '#{fullname}' as a collaborator."
        end
      end
    end
    redirect_to :controller => :browse, :action => :one_model, :id => params[:node_id]
  end
end
