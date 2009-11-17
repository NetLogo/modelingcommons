class AdminController < ApplicationController

  before_filter :require_login
  before_filter :require_administrator

  def index
  end

  def view_all_people
    @people = Person.find(:all, :order => "id")
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
    @models = Node.models
  end
end
