class ModelsController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @model_pages, @models = paginate :models, :per_page => 10
  end

  def show
    @model = Model.find(params[:id])
  end

  def new
    @model = Model.new
    @tags = Tag.find_all
  end

  def create
    @model = Model.new(params[:model])
    @model.tags = Tag.find(@params[:tag_ids]) if @params[:tag_ids]
    if @model.save
      flash[:notice] = 'Model was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @model = Model.find(params[:id])
    @tags = Tag.find_all
  end

  def update
    @model = Model.find(params[:id])
    @model.tags = Tag.find(@params[:tag_ids]) if @params[:tag_ids]
    if @model.update_attributes(params[:model])
      flash[:notice] = 'Model was successfully updated.'
      redirect_to :action => 'show', :id => @model
    else
      render :action => 'edit'
    end
  end

  def destroy
    Model.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
