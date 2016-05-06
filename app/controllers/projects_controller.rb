# Controller to deal witih projects

class ProjectsController < ApplicationController

  before_filter :require_login, :only => [:new, :create, :add_model, :remove_model]

  def index
    @projects = Project.all
    if @person
      @models_to_add = @person.models.select {|model| !model.projects.member?(@project)}.sort_by{|model| model.name.downcase}.map {|model| [model.name, model.id]}
    else
      @models_to_add = []
    end
  end

  def new
  end

  def create
    @project = Project.find_or_create_by_name(:name => params[:project_name],
                                              :person => @person)

    if @project.save
      flash[:notice] = "Successfully created project '#{@project.name}'"
    else
      flash[:notice] = "Could not create the project '#{@project.name}'"
    end

    redirect_to :controller => :account, :action => :mypage
  end

  def show
    @project = Project.find(params[:id])

    if @person
      @models_to_add = @person.models.select {|model| !model.projects.member?(@project)}.sort_by{|model| model.name.downcase}.map {|model| [model.name, model.id]}
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

    NodeProject.create!(node_id:model.id, project_id:project.id)

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
  
  def download
    project = Project.find(params[:id])
    send_file(project.create_zipfile(@person), :filename => project.zipfile_name, :type => 'application/zip', :disposition => "inline")
  end
  
end
