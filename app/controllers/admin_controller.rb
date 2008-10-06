class AdminController < ApplicationController

  before_filter :require_administrator

  def index
  end

  def view_all_people
    @people = Person.find(:all,
                          :order => "id")
  end

  def view_person_actions
    person_id = params[:id]
    if person_id.blank?
      flash[:notice] = "No person was specified; try again."
      redirect_to :back
      return
    end

    @actions = LoggedAction.find_all_by_person_id(person_id,
                                                  :order => "logged_at")
    render :template => "admin/view_actions"
  end

  def view_all_actions
    @actions = LoggedAction.find(:all,
                                 :order => "logged_at")
    render :template => "admin/view_actions"
  end

  def view_all_models
    @models = Nlmodel.find(:all, :order => "name")
  end

  def add_news_posting
  end

  def create_news_posting
    params[:new_posting][:person_id] = @person.id
    NewsItem.create(params[:new_posting])

    flash[:notice] = "Successfully added posting."
    redirect_to :back
  end

end
