# Controller to deal witih projects

class ProjectsController < ApplicationController

  def index
    @projects = Project.all
  end

  def new
  end

  def create
    @project = Project.create!(:name => params[:project_name])

    flash[:notice] = "Successfully created the project '#{@project.name}'"
    redirect_to :controller => :account, :action => :mypage
  end

  def show
    @project = Project.find(params[:id])

    if @person
      @models_to_add = @person.models.select {|m| !m.projects.member?(@project)}.sort_by{|m| m.name.downcase}.map {|m| [m.name, m.id]}
      else
      @models_to_add = []
    end
  end

  def find
    render :text => "You are on the 'find' page"
  end

  def add_model
    project = Project.find(params[:project_id])
    model = Node.find(params[:model_id])

    project.nodes << model

    if project.save
      flash[:notice] = "Added model '#{model.name}' to project '#{project.name}'"
    else
      flash[:notice] = "Error adding model '#{model.name}' to project '#{project.name}'"
    end

    redirect_to :controller => :projects, :action => :show, :id => project.id
  end

  def remove_model
    project = Project.find(params[:id])
    model = Node.find(params[:model_id])

    if project.nodes.delete(model)
      flash[:notice] = "Removed model '#{model.name}' from project '#{project.name}'"
    else
      flash[:notice] = "Error removing model '#{model.name}' from project '#{project.name}'"
    end

    redirect_to :controller => :projects, :action => :show, :id => project.id
  end

end
