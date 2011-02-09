require 'diff/lcs'
require 'diff/lcs/hunk'
require 'diff/lcs/string'
require 'graphviz_r'
require 'zip/zip'

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  before_filter :get_person
  before_filter :log_one_action

  def get_person
    person_id = session[:person_id]
    @person = Person.find(person_id)
  rescue
    @person = nil
  end

  def require_login
    if @person.nil?
      flash[:notice] = "You must log in before proceeding."
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

  def check_visibility_permissions
    logger.warn "[check_visibility_permissions] visible to user? Answer: #{@model.visible_to_user?(@person)}"

    return true if @model.nil? or @model.visible_to_user?(@person)
    logger.warn "[check_visibility_permissions] Model ID is '#{@model.id}'"

    flash[:notice] = "You do not have permission to view this model."

    if @person
      logger.warn "[check_visibility_permissions] Redirecting to my page"
      redirect_to :controller => :account, :action => :mypage
    else
      logger.warn "[check_visibility_permissions] Redirecting to login"
      redirect_to :controller => :account, :action => :login
    end
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
      @model.author?(@person)

    # If only the group can see this model, then get the model's group, and
    # determine if @person is a member of the group.
    if @model.group
      return true if @model.changeability.short_form == 'g' and @model.group.members.member?(@person)
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

    @model = Node.find(params[:id])
    @node = @model
  rescue
    flash[:notice] = "No model with ID '#{params[:id]}'"
    redirect_to :controller => :account, :action => :mypage
  end

  def all_whats_new
    how_new_is_new = 2.weeks.ago

    @recent_members = Person.created_since(how_new_is_new)
    @recent_models = Node.created_since(how_new_is_new)
    @updated_models = Node.updated_since(how_new_is_new)
    @recent_postings = Posting.created_since(how_new_is_new)
    @recent_tags = Tag.created_since(how_new_is_new)
    @recent_tagged_models = TaggedNode.created_since(how_new_is_new)

    @all_whats_new = [@recent_members, @recent_models, @updated_models, @recent_postings,
                      @recent_tags, @recent_tagged_models].flatten.sort_by {|new_item| new_item.updated_at}.reverse
  end

end
