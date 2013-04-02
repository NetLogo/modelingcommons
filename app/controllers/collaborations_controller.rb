# Controller to deal with collaborations

class CollaborationsController < ApplicationController

  before_filter :require_login

  def create
    return if params[:person_name].blank?
    @node = Node.find(params[:node_id])

    if params[:collaborator_type_id].blank? 
      message = "No collaboration type indicated; ignoring."
      
    elsif @node.author?(@person)
      collaborator = Person.first(:conditions => ["first_name || ' ' || last_name = ?", 
                                                  params[:person_name]])

      if @node.author?(collaborator)
        message = "Not adding '#{collaborator.fullname}', since they are already an author."
      else
        collaboration = Collaboration.new(:node => @node,
                                          :person => collaborator,
                                          :collaborator_type_id => params[:collaborator_type_id])
        if collaboration.save
          message = "Successfully added #{collaborator.fullname} as a collaborator."
        else
          message = "Could not create the collaboration"
        end
      end

    else
      message = 'You cannot set collaborators for this model'
    end

    respond_to do |format| 
      format.html do
        flash[:notice] = message
        redirect_to :back 
      end
      format.json { render :json => { :message => message } }
    end
  end
end
