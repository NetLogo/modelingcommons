# Controller that handles administrative functions

class AdminController < ApplicationController

  before_filter :require_login
  before_filter :require_administrator

  def index
  end

  def view_all_people
    @people = Person.all
  end

  def view_person_actions
    person_id = params[:id]
    if person_id.blank?
      flash[:notice] = "No person was specified; try again."
      redirect_to :back
      return
    end

    @actions = LoggedAction.paginate(:page => params[:page],
                                     :conditions => { :person_id => person_id},
                                     :order => "logged_at")
    render :template => "admin/view_actions"
  end

  def view_all_actions
    @actions = LoggedAction.paginate(:page => params[:page],
                                     :order => 'logged_at ASC')

    render :template => "admin/view_actions"
  end

  def view_all_models
    @models = Node.all
  end

  def become_user
    user_to_become = Person.find(params[:id])

    if user_to_become.administrator?
      flash[:notice] = "Sorry, but you cannot become an administrator."
      redirect_to :back
    else
      session[:person_id] = user_to_become.id
      flash[:notice] = "You are now logged in as '#{user_to_become.fullname}'."
      redirect_to :controller => :account, :action => :mypage
    end
  end
  
  def update_project_images
    Project.all.each {|p| p.create_project_image}
    flash[:notice] = 'Project images updated'
    redirect_to :controller => :account, :action => :mypage
  end
end
