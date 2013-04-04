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
        message = "Not adding '#{collaborator.fullname}', since they are already a collaborator."
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

  def destroy
    @model = Node.find_by_id(params[:node_id])
    if @model.nil?
      message = 'No such model'
    elsif @model.author?(@person)
      collaboration = Collaboration.find_by_node_id_and_person_id(@model.id, @person.id)
      collaboration.destroy
      flash[:notice] = "Removed you as a collaborator"
      message = 'ok'
    else
      message = "Not adding '#{collaborator.fullname}', since they are already a collaborator."
    end
    render :json => { :message => message }
  end

end
