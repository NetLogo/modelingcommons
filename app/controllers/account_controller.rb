class AccountController < ApplicationController

  before_filter :require_login, :only => [:edit, :update, :logout, :tags]

  def new
    @new_person = Person.new
  end

  def create
    @new_person = Person.new(params[:new_person])

    begin
      @new_person.save!
      flash[:notice] = "Congratulations, #{@new_person.first_name}!  You are now registered with the Modeling Commons.  We're delighted that you've joined us."
      Notifications.deliver_signup(@new_person)
      session[:person_id] = @new_person.id
      redirect_to :controller => :account, :action => :mypage
    rescue Exception => exception
      render :action => :new
    end

  end

  def edit
  end

  def tags
  end

  def update
    begin
      @person.update_attributes!(params[:person])
      flash[:notice] = "Successfully updated your account."
      redirect_to :back
    rescue Exception => exception
      flash[:notice] = "Error updating your account: '#{exception.message}'"
      redirect_to :back
    end

  end

  def login
  end

  def login_action
    if params[:email_address].blank? or params[:password].blank?
      flash[:notice] = "You must provide an e-mail address and password in order to log in."
      redirect_to :controller => :account, :action => :login
      return
    end

    @person =
      Person.find_by_email_address_and_password(params[:email_address].strip,
                                                params[:password].strip)

    if @person.blank?
      flash[:notice] = "Sorry, but no user exists with that e-mail address and password.  Please try again."
      redirect_to :back
      return
    end

    flash[:notice] = "Welcome back to the Commons, #{@person.first_name}!"
    session[:person_id] = @person.id
    redirect_to :controller => :account, :action => :mypage
  end

  def logout
    @person = nil
    session[:person_id] = nil
    flash[:notice] = "You have been logged out.  Please come back soon!"
    redirect_to :controller => :account, :action => :login
  end

  def mypage
    if @person.nil? and params[:id].blank?
      flash[:notice] = "You must first log in."
      redirect_to :controller => :account, :action => :login
      return
    end

    if params[:id].blank?
      @the_person = @person
    else
      @the_person = Person.find(params[:id].to_i)
    end

    how_new_is_new = 6.months.ago

    @questions = Posting.find(:all,
                              :conditions => ["is_question = true AND created_at >= ? AND answered_at IS NULL", how_new_is_new],
                              :order => "created_at DESC")

    @recent_tags = @the_person.tags.select { |t| t.created_at >= how_new_is_new}
    @recent_tagged_models =
      @the_person.tagged_nodes.select { |tn| tn.created_at >= how_new_is_new}
    @tag_events =
      [@recent_tags, @recent_tagged_models].flatten.sort_by { |t| t.created_at}.reverse

    if @tag_events.length > 10
      @tag_events = @tag_events[0..9]
    end

    # Model updates
    @recent_models = @the_person.models.select { |model| model.created_at >= how_new_is_new }.sort_by { |model| model.created_at }.reverse
    @model_events = @recent_models;

    @group_recent_models = @the_person.models.select { |model| model.group and model.created_at >= how_new_is_new }.sort_by { |model| model.created_at }.reverse
    @group_model_events = @group_recent_models.select { |model| model.group.members.include?(@person)}

    # most-viewed models
    @most_viewed = LoggedAction.find_by_sql("SELECT COUNT(DISTINCT person_id), node_id
                                                FROM Logged_Actions
                                               WHERE url ILIKE '/browse/one_model%'
                                                 AND node_id IS NOT NULL
                                            GROUP BY node_id
                                            ORDER BY count DESC
                                               LIMIT 10;").map { |la| [la.node, la.count]}

    # most-downloaded models
    @most_downloaded = LoggedAction.find_by_sql("SELECT COUNT(DISTINCT person_id), node_id
                                                   FROM Logged_Actions
                                                  WHERE url ILIKE '/browse/download_model%'
                                                    AND node_id IS NOT NULL
                                               GROUP BY node_id
                                               ORDER BY count DESC
                                                  LIMIT 10;").map { |la| [la.node, la.count]}

    # most-applied tags
    @most_popular_tags =
      TaggedNode.count(:group => "tag_id",
                       :order => "count_all DESC",
                       :limit => 10)
    @most_popular_tags = @most_popular_tags.map { |tag| [Tag.find(tag[0]), tag[1]]}

    # most-recommended models
    @most_recommended_models =
      Recommendation.count(:group => "node_id",
                           :order => "count_all DESC",
                           :limit => 10)
    @most_recommended_models = @most_recommended_models.map { |node| [Node.find(node[0]), node[1]]}
  end

  def mygroups
    render :layout => false
  end

  def send_password_action
    email_address = params[:email_address]

    if email_address.blank?
      flash[:notice] = "You must enter an e-mail address to receive a reminder."
      redirect_to :controller => :account, :action => :send_password
      return
    end

    @person = Person.find_by_email_address(email_address)

    if email_address.index('@').nil?
      flash[:notice] = "Sorry, but '#{email_address}' is not a valid e-mail address.  Please try again."
      redirect_to :back
    elsif @person
      Notifications.deliver_password_reminder(@person)
      flash[:notice] = "A password reminder was sent to your e-mail address."
      redirect_to :controller => :account, :action => :login
    else
      flash[:notice] = "Sorry, but '#{email_address}' is not listed in our system.  Please register."
      redirect_to :back
    end

  end

  def follow
    if params[:id].blank?
      flash[:notice] = "You must indicate the person whose actions you wish to follow."
      logger.warn "[follow] Sending user back; no ID specified"
      redirect_to :back
      return
    end

    @new_things = [ ]
    how_recent = 6.months.ago

    @the_person = Person.find(params[:id])
    @the_person.node_versions.find(:all, :conditions => ["created_at >= ? ", how_recent]).each do |nv|

      @new_things <<
        {:id => nv.id,
        :node_id => nv.node_id,
        :node_name => nv.node.name,
        :date => nv.created_at,
        :description => "New version of '#{nv.node.name}' uploaded by '#{nv.person.fullname}'",
        :title => "Update to model '#{nv.node.name}'",
        :file_contents => nv.description}
    end


    @the_person.postings.find(:all, :conditions => ["created_at >= ? ", how_recent]).each do |posting|

      @new_things <<
        {:id => posting.id,
        :node_id => posting.node_id,
        :node_name => posting.node.name,
        :date => posting.created_at,
        :description => "Posting by '#{posting.person.fullname}' about the '#{posting.node.name}' model",
        :title => posting.title,
        :file_contents => posting.body}
    end

    @the_person.tagged_nodes.find(:all, :conditions => ["created_at >= ? ", how_recent]).each do |tn|

      @new_things <<
        {:id => tn.id,
        :node_id => tn.node_id,
        :node_name => tn.node.name,
        :date => tn.created_at,
        :description => "Model '#{tn.node.name}' tagged with '#{tn.tag.name}' by '#{tn.person.fullname}'",
        :title => "Model '#{tn.node.name}' tagged with '#{tn.tag.name}' by '#{tn.person.fullname}'",
        :file_contents => "<p>'#{tn.person.fullname} tagged the '#{tn.node.name}' model</p>"
      }
    end

    respond_to do |format|
      format.html { @new_things }
      format.atom { @new_things }
    end
  end

  def models
    @the_person = Person.find(params[:id])
  end

end
