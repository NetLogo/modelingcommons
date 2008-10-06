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

end
