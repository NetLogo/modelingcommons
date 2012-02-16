# Controller to deal witih projects
require 'RMagick'

class ProjectsController < ApplicationController

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
    return
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
  def image
    project = Project.find(params[:id])
    id=project.nodes.fetch(0).id
    response.headers["Content-type"] = 'image/png'
    list = Magick::ImageList.new
    #list.from_blob(project.nodes.fetch(0).preview.contents.to_s)
    project.nodes.each do |model| 
      if !model.preview.blank?
        list.from_blob(model.preview.contents.to_s)
      end
    end
    m = list.montage {
      self.geometry = '60x60+0+0'
      self.tile = '2x2'
    } .first
    m.format = 'png'
    render :text => m.to_blob, :layout => false
  end

end
