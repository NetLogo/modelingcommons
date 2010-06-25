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

    @models = Node.search(@original_search_term, @person)

    logger.warn "[SearchController#search_action] [#{Time.now}] Getting matching model authors"
    @author_match_models = [ ]
    Person.search(@original_search_term).each { |person| @author_match_models += person.models }
    @author_match_models = @author_match_models.uniq.select { |node| node.visible_to_user?(@person)}

    logger.warn "[SearchController#search_action] [#{Time.now}] Getting matching model tags"
    @tag_match_models = [ ]
    Tag.search(@original_search_term).each {  |tag| @tag_match_models += tag.nodes }
    @tag_match_models = @tag_match_models.uniq.select { |node| node.visible_to_user?(@person)}

    logger.warn "[SearchController#search_action] [#{Time.now}] Getting matching info tabs"
    @info_match_models = NodeVersion.info_keyword_matches(@original_search_term).map {|nv| nv.node}.uniq.select { |node| node.visible_to_user?(@person)}

    logger.warn "[SearchController#search_action] [#{Time.now}] Getting matching procedure tabs"
    @procedures_match_models = NodeVersion.procedures_keyword_matches(@original_search_term).map {|nv| nv.node}.uniq.select { |node| node.visible_to_user?(@person)}

    logger.warn "[SearchController#search_action] [#{Time.now}] Done"
  end

end
