class ProjectsController < ApplicationController

  def index
    @projects = Project.all
  end

  def new
  end

  def create
    @project = Project.create!(:name => params[:project_name])

    flash[:notice] = "Successfully created the project '#{@project.name}'"
    redirect_to :controller => :account, :action => :index
  end

  def show
    @project = Project.find(params[:id])
  end

  def find
    render :text => "You are on the 'find' page"
  end

end
