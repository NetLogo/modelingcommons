# Controller to deal with search

class SearchController < ApplicationController

  def search_action
    if params[:search_term].blank?
      flash[:notice] = "You must enter a search term in order to search."
      redirect_to :controller => :account, :action => :mypage
      return
    end

    @original_search_term = params[:search_term].downcase

    @models = Node.search(@original_search_term, @person)

    @author_match_models = [ ]
    Person.search(@original_search_term).each { |person| @author_match_models += person.models }
    @author_match_models = @author_match_models.uniq.select { |node| node.visible_to_user?(@person)}

    @tag_match_models = [ ]
    Tag.search(@original_search_term).each {  |tag| @tag_match_models += tag.nodes }
    @tag_match_models = @tag_match_models.uniq.select { |node| node.visible_to_user?(@person)}

    matching_versions = Version.basic_search(@original_search_term)

    @info_match_models = matching_versions.select {|v| v.info_tab.index(@original_search_term)}.map {|nv| nv.node}.select { |node| node.visible_to_user?(@person)}.uniq
    @procedures_match_models = matching_versions.select {|v| v.procedures_tab.index(@original_search_term)}.map {|nv| nv.node}.select { |node| node.visible_to_user?(@person)}.uniq

  end

end
