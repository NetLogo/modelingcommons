# Controller to deal with search

class SearchController < ApplicationController

  def search_action
    logger.warn "[SearchController#search_action] [#{Time.now}] Entered"

    if params[:search_term].blank?
      flash[:notice] = "You must enter a search term in order to search."
      redirect_to :controller => :account, :action => :mypage
      return
    end

    logger.warn "[SearchController#search_action] [#{Time.now}] Downcasing search term"
    @original_search_term = params[:search_term].downcase

    logger.warn "[SearchController#search_action] [#{Time.now}] Getting matching model names"
    @models = Node.find(:all,
                        :conditions => [ "position( ? in lower(name) ) > 0 ", @original_search_term] ).select { |n| n.visible_to_user?(@person)}

    logger.warn "[SearchController#search_action] [#{Time.now}] Getting matching model authors"
    @author_match_models = [ ]
      # @viewable_models.select { |model| model.people.map { |person| person.fullname}.join(" ").downcase.index(@original_search_term)}

    logger.warn "[SearchController#search_action] [#{Time.now}] Getting matching model tags"
    @tag_match_models = [ ]
      # @viewable_models.select { |model| model.tags.map { |tag| tag.name}.join(' ').downcase.index(@original_search_term)}

    logger.warn "[SearchController#search_action] [#{Time.now}] Getting matching info tabs"
    @info_match_models = NodeVersion.all(:info_keyword_index => @original_search_term).map {|nv| nv.node}.select { |n| n.visible_to_user?(@person)}

    logger.warn "[SearchController#search_action] [#{Time.now}] Getting matching procedure tabs"
    @procedures_match_models = NodeVersion.all(:procedures_keyword_index => @original_search_term).map {|nv| nv.node}.select { |n| n.visible_to_user?(@person)}

    logger.warn "[SearchController#search_action] [#{Time.now}] Done"
  end


end
