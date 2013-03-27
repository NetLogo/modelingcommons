class CollaboratorTypesController < ApplicationController
  # GET /collaborator_types
  # GET /collaborator_types.xml
  def index
    @collaborator_types = CollaboratorType.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @collaborator_types }
    end
  end

  # GET /collaborator_types/1
  # GET /collaborator_types/1.xml
  def show
    @collaborator_type = CollaboratorType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @collaborator_type }
    end
  end

  # GET /collaborator_types/new
  # GET /collaborator_types/new.xml
  def new
    @collaborator_type = CollaboratorType.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @collaborator_type }
    end
  end

  # GET /collaborator_types/1/edit
  def edit
    @collaborator_type = CollaboratorType.find(params[:id])
  end

  # POST /collaborator_types
  # POST /collaborator_types.xml
  def create
    @collaborator_type = CollaboratorType.new(params[:collaborator_type])

    respond_to do |format|
      if @collaborator_type.save
        format.html { redirect_to(@collaborator_type, :notice => 'CollaboratorType was successfully created.') }
        format.xml  { render :xml => @collaborator_type, :status => :created, :location => @collaborator_type }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @collaborator_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /collaborator_types/1
  # PUT /collaborator_types/1.xml
  def update
    @collaborator_type = CollaboratorType.find(params[:id])

    respond_to do |format|
      if @collaborator_type.update_attributes(params[:collaborator_type])
        format.html { redirect_to(@collaborator_type, :notice => 'CollaboratorType was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @collaborator_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /collaborator_types/1
  # DELETE /collaborator_types/1.xml
  def destroy
    @collaborator_type = CollaboratorType.find(params[:id])
    @collaborator_type.destroy

    respond_to do |format|
      format.html { redirect_to(collaborator_types_url) }
      format.xml  { head :ok }
    end
  end
end
