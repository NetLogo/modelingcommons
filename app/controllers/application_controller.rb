# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :transparent_message

  before_filter :get_person
  before_filter :log_one_action
  before_filter :get_node_types

  def get_person
    person_id = session[:person_id]
    @person = Person.find(person_id)
  rescue
    @person = nil
  end

  def require_login
    if @person.nil?

      if (params[:controller] != 'account' and params[:action] != 'mypage')
        flash[:notice] = "You must log in before proceeding."
      end
      logger.warn "[require_login] Redirecting user to the login page"

      redirect_to :controller => :account, :action => :login
      return false
    end
  end

  def require_administrator
    if not @person.administrator?
      flash[:notice] = "Only administrators may visit this URL."
      redirect_to :controller => :account, :action => :login
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

    # Get the node ID
    if @model
      node_id = @model.id
    elsif @node
      node_id = @node.id
    else
      node_id = nil
    end

    browser_info = request.env['HTTP_USER_AGENT'] || 'No browser info passed'
    ip_address = request.remote_ip || 'No IP address passed'

    begin
      session_yaml = session.to_yaml
    rescue
      session_yaml = '(Cannot dump session.to_yaml)'
    end

    LoggedAction.create(:person_id => person_id,
                        :controller => params[:controller],
                        :action => params[:action],
                        :logged_at => Time.now(),
                        :message => message,
                        :ip_address => ip_address,
                        :browser_info => browser_info,
                        :url => request.request_uri,
                        :params => params.to_yaml,
                        :session => session_yaml,
                        :cookies => cookies.to_yaml,
                        :flash => flash.to_yaml,
                        :referrer => request.env['HTTP_REFERER'],
                        :node_id => node_id)
  end

  def get_node_types
    @node_types = NodeType.find(:all)
  end

  def check_visibility_permissions
    return true if @model.nil? or @person.nil?

    logger.warn "[check_visibility_permissions] Checking visibility permissions for model '#{@model.id}' and person '#{@person.id}'"

    # This only applies if the node is a model
    return true unless @model.is_model?

    # If everyone can see this model, then deal with the simple case
    return true if @model.visibility.short_form == 'a'

    # If only the author can see this model, then deal with the simple case
    # Note that the "user" permission works for anyone who has already submitted
    # a version to this model.  Otherwise, things get a bit sticky.  I think.
    if @model.visibility.short_form == 'u' and @model.people.member?(@person)
      logger.warn "[check_visibility_permissions] Visiblity permission is 'u' and person '#{@person}' is in the member list.  Allowing."
      return true
    end

    # If only the group can see this model, then get the model's group, and
    # determine if @person is a member of the group.
    if @model.group
      if @model.visibility.short_form == 'g' and @model.group and @model.group.approved_members.member?(@person)
        logger.warn "[check_visibility_permissions] Visiblity permission is 'g' and person '#{@person}' is a member of group '#{@model.group.name}'.  Allowing."
        return true
      end
    end

    flash[:notice] = "You do not have permission to view this model."
    redirect_to :controller => :account, :action => :mypage
    return false
  end

  def check_changeability_permissions
    if @model.nil?

      if params[:new_document] and params[:new_document][:parent_node_id]
        @model = Node.find(params[:new_document][:parent_node_id])

      elsif params[:new_version] and params[:new_version][:node_id]
        @model = Node.find(params[:new_version][:node_id])
      end

    end

    if @model.nil?
      logger.warn "[check_changeability_permissions] Error -- model is nil.  Cannot upload."
      flash[:notice] = "Error detected; cannot upload.  Please notify the site administrator."
      return false
    end

    logger.warn "Checking changeability permissions for model '#{@model.to_yaml}' and person '#{@person.to_yaml}'"

    # This only applies if the node is a model
    return true unless @model.is_model?

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
    if @model.group
      return true if @model.changeability.short_form == 'g' and @model.group.approved_members.member?(@person)
    end

    flash[:notice] = "You do not have permission to modify this model."
    redirect_to :controller => :account, :action => :mypage
    return false
  end

  def get_model_from_id_param
    if params[:id].blank?
      flash[:notice] = "No model ID provided"
      redirect_to :back
      return
    end

    @model = Node.models.find(params[:id])
    @node = @model
  rescue
    render :text => "No model with ID '#{params[:id]}'"
    return
  end

  def all_whats_new
    how_new_is_new = 3.months.ago

    @recent_members = Person.find(:all,
                                  :order => 'created_at DESC',
                                  :conditions => ["created_at >= ?", how_new_is_new ])

    @recent_models = Node.models.find(:all,
                                      :order => 'created_at DESC',
                                      :conditions => ["created_at >= ?", how_new_is_new ])

    @updated_models = Node.models.find(:all,
                                       :order => 'updated_at DESC',
                                       :conditions => ["created_at >= ?", how_new_is_new ])

    @recent_postings = Posting.find(:all,
                                    :order => 'created_at DESC',
                                    :conditions => ["created_at >= ?", how_new_is_new ])

    @recent_tags = Tag.find(:all, :order => 'created_at DESC',
                            :conditions => ["created_at >= ?", how_new_is_new ])

    @recent_tagged_models = TaggedNode.find(:all, :order => 'created_at DESC',
                                            :conditions => ["created_at >= ?", how_new_is_new ])

    @all_whats_new = [@recent_members, @recent_models, @updated_models, @recent_postings,
                      @recent_tags, @recent_tagged_models].flatten.sort_by {|n| n.updated_at}.reverse
  end

end
