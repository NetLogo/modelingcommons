# Controller to deal with collaborations

class CollaborationsController < ApplicationController

  before_filter :require_login

  def create
    @collaboration = Collaboration.new(params[:collaboration])
    
    if @collaboration.save
      flash[:notice] = "Successfully added collaboration"
    else
      logger.warn "[CollaborationsController#create] errors saving collaboration: '#{@collaboration.errors.inspect}'"
      flash[:notice] = "Could not create the collaboration"
    end

    redirect_to :back
  end
end
