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
                                                    params[:person_name]]) ||
          Person.find_by_email_address(params[:person_email])
        
        if collaborator
          if @node.author?(collaborator)
            message = "Not adding '#{collaborator.fullname}', since they are already a collaborator."
          else
            
            collaboration = Collaboration.new(:node => @node,
                                              :person => collaborator,
                                              :collaborator_type_id => params[:collaborator_type_id])

            if collaboration.save
              message = "Successfully added #{collaborator.fullname} as a collaborator."
              success = true
            else
              message = "Could not create the collaboration"
            end
          end
        elsif params[:person_email].present?
          nmc = NonMemberCollaborator.find_or_create_by_email(params[:person_email], 
                                                              {name:params[:person_name]})

          if @node.non_member_collaborators.member?(nmc)
            message = "This person ('#{nmc.email}') is already a collaborator"
            success = false

          else
            collaboration = 
              NonMemberCollaboration.create(non_member_collaborator_id:nmc.id,
                                            node_id:@node.id, 
                                            collaborator_type_id: params[:collaborator_type_id],
                                            person_id:@person.id)

            if collaboration.valid?
              message = "Added non-member collaborator '#{params[:person_email]}'"
              success = true
            else
              message = "Error adding non-member collaborator '#{params[:person_email]}'"
            end
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
