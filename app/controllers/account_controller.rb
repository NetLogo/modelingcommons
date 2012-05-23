# Controller that handles creation and working with user accounts

class AccountController < ApplicationController

  before_filter :require_login, :only => [:edit, :update, :logout, :tags, :mygroups]

  def new_front_page
     render :layout => 'application_nomargin'
  end
  def new
    @new_person = Person.new
  end

  def create
    @new_person = Person.new(params[:new_person])

    if @new_person.save
      flash[:notice] = "Congratulations, #{@new_person.first_name}!  You are now registered with the Modeling Commons.  We're delighted that you've joined us."

      Notifications.deliver_signup(@new_person, params[:new_person][:password])
      session[:person_id] = @new_person.id
      redirect_to :controller => :account, :action => :mypage
    else
      render :action => :new
    end
  end

  def edit
  end

  def tags
  end

  def update
    if params[:person][:password].blank?
      params[:person].delete(:password)
      params[:person].delete(:password_confirmation)
    end

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
    render :layout => 'application_nomargin'
  end

  def login_action
    if params[:email_address].blank? or params[:password].blank?
      flash[:notice] = "You must provide an e-mail address and password in order to log in."
      redirect_to :controller => :account, :action => :login
      return
    end

    @person = Person.find_by_email_address(params[:email_address].strip)
    if @person.nil?
      logger.warn "Attempted login with non-existent email_address '#{params[:email_address]}'"
      flash[:notice] = "Sorry, but no user exists with that e-mail address and password.  Please try again."
      redirect_to :back
      return
    end

    encrypted_user_input = Person.encrypted_password(@person.salt, params[:password])
    if encrypted_user_input != @person.password
      logger.warn "Attempted login for email_address '#{params[:email_address]}' with incorrect password '#{params[:password]}'"
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

    logger.warn "[AccountController#mypage] #{Time.now} enter"
    return redirect_to :controller => :account, :action => :login if (@person.nil? and params[:id].blank?)

    if params[:id].blank?
      @the_person = @person
    else
      @the_person = Person.find(params[:id].to_i, :include => [:postings, :tags, :tagged_nodes])
    end

    how_new_is_new = 2.weeks.ago

    logger.warn "[AccountController#mypage] #{Time.now} before @questions"
    @questions = Posting.unanswered_questions.select { |question| question.node.visible_to_user?(@person) and question.created_at >= how_new_is_new }

    logger.warn "[AccountController#mypage] #{Time.now} before @recent_tags"
    @recent_tags = @the_person.tags.select { |tag| tag.created_at >= how_new_is_new}

    logger.warn "[AccountController#mypage] #{Time.now} before @recent_tagged_models"
    @recent_tagged_models = @the_person.tagged_nodes.select { |tagged_node| tagged_node.node.visible_to_user?(@person) and tagged_node.created_at >= how_new_is_new}

    logger.warn "[AccountController#mypage] #{Time.now} before @tag_events"
    @tag_events = [@recent_tags, @recent_tagged_models].flatten.sort_by { |tag| tag.created_at}.reverse
    @tag_events = @tag_events[0..9] if @tag_events.length > 10

    logger.warn "[AccountController#mypage] #{Time.now} before all model updates"
    @all_model_events = Node.all(:order => 'updated_at DESC', 
                                 :limit => 30).select { |node| node.visible_to_user?(@person) and node.updated_at >= how_new_is_new}

    logger.warn "[AccountController#mypage] #{Time.now} before user/group model updates"
    # Model updates
    @model_events = [ ]
    @group_recent_models = [ ]

    @the_person.models.reverse.each_with_index do |model, index|
      break if index > 30

      if model.updated_at >= how_new_is_new
        @model_events << model 
        @group_recent_models << model if model.group
      end
    end

    @group_model_events = @group_recent_models.select { |model| model.group.members.include?(@person)}
    @model_events = @model_events.select { |model| model.visible_to_user?(@person)}

    logger.warn "[AccountController#mypage] #{Time.now} before most-viewed models"

    # all-time most-viewed models
    @all_time_most_viewed = Node.all_time_most_viewed.map { |la| [la.node, la.count]}
    @all_time_most_viewed = @all_time_most_viewed.select {|model_array| model_array[0].visible_to_user?(@person)}[0..9]

    # most-viewed models
    @most_viewed = Node.most_viewed.map { |la| [la.node, la.count]}
    @most_viewed.reject! { |model_array| model_array[0].nil? }
    @most_viewed = @most_viewed.select {|model_array| model_array[0].visible_to_user?(@person)}[0..9]

    logger.warn "[AccountController#mypage] #{Time.now} before most-downloaded models"
    # most-downloaded models
    @most_downloaded = Node.most_downloaded.map { |la| [la.node, la.count] }
    @most_downloaded = @most_downloaded.select {|model_array| model_array[0] and model_array[0].visible_to_user?(@person)}[0..9]


    logger.warn "[AccountController#mypage] #{Time.now} before most-applied tags"
    # most-applied tags
    @most_popular_tags =
      TaggedNode.count(:group => "tag_id",
                       :order => "count_all DESC",
                       :limit => 20).map { |tag| [Tag.find(tag[0]), tag[1]]}

    logger.warn "[AccountController#mypage] #{Time.now} before most-recommended models"
    # most-recommended models
    @most_recommended_models =
      Recommendation.count(:group => "node_id",
                           :order => "count_all DESC",
                           :limit => 20).map { |node| [Node.find_by_id(node[0]), node[1]]}.select { |node_array| node_array[0].visible_to_user?(@person) if node_array[0]}

    logger.warn "[AccountController#mypage] #{Time.now} exit"
    render :layout => 'application_nomargin'
  end

  def reset_password_action
    email_address = params[:email_address].to_s

    if email_address.index('@').nil?
      flash[:notice] = "Sorry, but '#{email_address}' is not a valid e-mail address.  Please try again."
      redirect_to :controller => :account, :action => :send_password
      return
    end

    @person = Person.find_by_email_address(email_address)

    if @person
      new_password = ''
      8.times { new_password << ('a'..'z').to_a.shuffle.first }

      # Do this to deal with people who haven't signed the consent form,
      # so their model won't pass validation
      encrypted_password = Person.encrypted_password(@person.salt, new_password)
      @person.update_attribute(:password, encrypted_password)

      Notifications.deliver_password_reminder(@person, new_password)
      flash[:notice] = "Your password has been reset.  The new password was sent to your e-mail address."
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

    if @person
      @new_things +=
        @person.node_versions.select { |node_version| node_version.created_at >= how_recent }.map{ |node_version| node_version.new_thing } 
      @new_things +=
        @person.postings.select { |person| person.created_at >= how_recent }.map{ |person| person.new_thing } 
      @new_things +=
        @person.tagged_nodes.select { |tagged_node| tagged_node.created_at >= how_recent }.map{ |tagged_node| tagged_node.new_thing } 
    end

    respond_to do |format|
      format.html { @new_things }
      format.atom { @new_things }
    end
  end

  def models
    @the_person = Person.find(params[:id])
    render :layout => 'application_nomargin'
  end
  def groups
    render :layout => 'application_nomargin'
  end
  def find_people
    query = params[:query].blank? ? "" : params[:query].downcase
    count = params[:count].blank? ? 10 : params[:count].to_i
    render :json => Person.search(query).sort {|a, b| a.fullname.downcase <=> b.fullname.downcase}[0..count-1].map {|person| {:id => person.id, :html => render_to_string(:partial => 'selectable_person', :locals => { :person => person})}}
  end
  def get_feed
    @all_model_events = Node.all(:order => 'updated_at DESC', :limit => 30).select { |node| node.visible_to_user?(@person)}
    @tag_events = TaggedNode.all(:order => 'updated_at DESC', :limit => 30)
    #render :json => @all_model_events.map {|model| {:created_at => model.created_at, :author => {:name => model.person.fullname, :id => model.person.id, :url => url_for(:controller => :account, :action => :mypage, :id => model.person.id, :image => model.person.avatar.url(:thumb))}, :name => model.name, :id => model.id}}
    render :json => @tag_events.map {|tagged| {:nodename => tagged.node.name, :tag_node_id => tagged.id, :node_id => tagged.node.id, :date_tagged => tagged.created_at, :tag_id => tagged.tag.id, :comment => tagged.comment}}
  end

end
