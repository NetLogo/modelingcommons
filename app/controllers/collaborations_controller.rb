# Controller to deal with collaborations

class CollaborationsController < ApplicationController

  before_filter :require_login

  def create
    
    
    if params[:node_id].blank?
      message = "You must provide a model to add a collaborator to"
      
    elsif params[:person_name].blank?
      message = "You must enter a person's name."

    elsif params[:collaborator_type_id].blank? 
      message = "No collaboration type indicated; ignoring."
      
    else
      @node = Node.find(params[:node_id])
      if CollaboratorType.find_by_id(params[:collaborator_type_id]).nil?
        message = "No such collaborator type"
        
      elsif not @node.author?(@person)
        message = 'You cannot set collaborators for this model'
        
      else
        collaborator = Person.first(:conditions => ["first_name || ' ' || last_name = ?", 
                                                    params[:person_name]])
  
        if @node.author?(collaborator)
          message = "Not adding '#{collaborator.fullname}', since they are already a collaborator."
        else
          
          collaboration = Collaboration.new
          collaboration.assign_attributes(:node => @node,
                                            :person => collaborator,
                                            :collaborator_type_id => params[:collaborator_type_id])
          if collaboration.save
            message = "Successfully added #{collaborator.fullname} as a collaborator."
            success = true;
            
          else
            message = "Could not create the collaboration"
          end
        end
        
      end
      
    end
    

    respond_to do |format| 
      format.html do
        flash[:notice] = message
        redirect_to :back
      end
      if success
        @model = @node
        html = render_to_string(:partial => "collaborations/collaborator_list", :layout => false, :formats => 'html')
      end
      format.json { render :json => { :message => message, :html => html } }
    end
  end

  def destroy
    @model = Node.find_by_id(params[:node_id])
    if @model.nil?
      message = 'No such model'
    elsif @model.collaborations.size == 1
      message = 'Cannot remove the last collaborator'
    elsif @model.author?(@person)
      collaboration = Collaboration.find_by_node_id_and_person_id(@model.id, @person.id)
      
      if collaboration.name == 'Author'
        message = 'Cannot remove author collaborators'
      else
        collaboration.destroy
        message = "Removed you as a collaborator"
      end
    else
      message = "Not adding '#{@person.fullname}', since they are already a collaborator."
    end
    flash[:notice] = message
    redirect_to :back
  end

end
