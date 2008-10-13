# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  before_filter :get_person
  before_filter :require_login
  before_filter :log_one_action
  before_filter :get_node_types

  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_finish_session_id'

  def get_person
    person_id = session[:person_id]
    @person = Person.find(person_id)
  rescue
    @person = nil
  end

  def require_login
    if @person.nil?
      flash[:notice] = "You must log in before proceeding."

      redirect_to :controller => "account", :action => "login"
      return false
    end
  end

  def require_administrator
    if not @person.administrator?
      flash[:notice] = "Only administrators may visit this URL."
      redirect_to :controller => "account", :action => "login"
      return false
    end
  end

  def log_one_action(message='(No message)')
    # Get the person ID
    if @person.nil?
      person_id = nil
    else
      person_id = @person.id
    end

    browser_info = request.env['HTTP_USER_AGENT'] || 'No browser info passed'
    ip_address = request.remote_ip || 'No IP address passed'

    LoggedAction.create(:person_id => person_id,
                        :logged_at => Time.now(),
                        :message => message,
                        :ip_address => ip_address,
                        :browser_info => browser_info,
                        :url => request.request_uri,
                        :params => params.to_yaml,
                        :session => session.to_yaml,
                        :cookies => cookies.to_yaml,
                        :flash => flash.to_yaml)
  end

  def get_node_types
    @node_types = NodeType.find(:all)
  end

  def check_visibility_permissions
    logger.warn "Checking visibility permissions for model '#{@model.id}' and person '#{@person.id}'"

    # This only applies if the node is a model
    return true unless @node.is_model?

    # If there's no model, then allow everything
    return true unless @model

    # If there's no person, then allow nothing
    return false unless @person

    # If everyone can see this model, then deal with the simple case
    return true if @model.visibility.short_form == 'a'

    # If only the author can see this model, then deal with the simple case
    # Note that the "user" permission works for anyone who has already submitted
    # a version to this model.  Otherwise, things get a bit sticky.  I think.
    if @model.visibility.short_form == 'u' and @model.people.member?(@person)
      logger.warn "Visiblity permission is 'u' and person '#{@person}' is in the member list.  Allowing."
      return true
    end

    # If only the group can see this model, then get the model's group, and
    # determine if @person is a member of the group.
    if @model.visibility.short_form == 'g' and @model.group.members.member?(@person)
      logger.warn "Visiblity permission is 'g' and person '#{@person}' is a member of group '#{@model.group.name}'.  Allowing."
      return true
    end

    flash[:notice] = "You do not have permission to view this model."
    redirect_to :controller => "account", :action => "login"
    return false
  end

  def check_changeability_permissions
    logger.warn "Checking changeability permissions for model '#{@model.to_yaml}' and person '#{@person.to_yaml}'"

    # This only applies if the node is a model
    return true unless @node.is_model?

    # If there's no model, then allow everything
    return true unless @model

    # If there's no person, then allow nothing
    return false unless @person

    # If everyone can see this model, then deal with the simple case
    return true if @model.changeability.short_form == 'a'

    # If only the author can see this model, then deal with the simple case
    # Note that the "user" permission works for anyone who has already submitted
    # a version to this model.  Otherwise, things get a bit sticky.  I think.
    return true if @model.changeability.short_form == 'u' and
      @model.people.member?(@person)

    # If only the group can see this model, then get the model's group, and
    # determine if @person is a member of the group.
    return true if @model.changeability.short_form == 'g' and
      @model.group.members.member?(@person)

    return false
  end


end
