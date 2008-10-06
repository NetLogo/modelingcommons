class SearchController < ApplicationController

  def index
    @models = Model.find_all
    @tags = Tag.find_all
  end
  
  def model_search
    logger.warn "Hello!"

    @search_name = params[:name_field] if params[:name_field]
    @search_info = params[:information_field] if params[:information_field]
    @search_tags = params[:tag_ids] if params[:tag_ids]
    @models = Model.find_all
    @tags = Tag.find_all
    if @search_name
      @result_models = Model.find(:all, :conditions => ["name like ? AND information like ?", "%" + @search_name + "%" , "%" + @search_info + "%"])
      @result_models.delete_if { |candidate|
        @delete = false
        if @search_tags
          for tag_id in @search_tags
            if not candidate.tags.include? Tag.find(tag_id)
              @delete = true
            end
          end
        end
        @delete
      }
    end
    render :action => 'model_search'
  end
  
  def run_model
    @model = Model.find(params[:id])
    render :action => 'run_model'
  end
end
