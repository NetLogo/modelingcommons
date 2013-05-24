# Controller to deal with search

class SearchController < ApplicationController

  def search_action
    if params[:search_term].blank?
      flash[:notice] = "You must enter a search term in order to search."
      redirect_to :controller => :account, :action => :mypage
      return
    end

    @original_search_term = params[:search_term].downcase
    @original_search_term.gsub!(/\W*\d+\W*/, ' ')
    @original_search_term.strip!

    @models = Node.search(@original_search_term, @person)

    @author_match_models = [ ]
    Person.search(@original_search_term).each { |person| @author_match_models += person.models }
    @author_match_models = @author_match_models.uniq.select { |node| node.visible_to_user?(@person)}

    @tag_match_models = [ ]
    Tag.search(@original_search_term).each {  |tag| @tag_match_models += tag.nodes }
    @tag_match_models = @tag_match_models.uniq.select { |node| node.visible_to_user?(@person)}

    matching_nodes = Version.text_search(@original_search_term).map { |v| v.node}.uniq.select { |n| n and n.visible_to_user?(@person) }

    @info_match_models = matching_nodes.select {|n| n.contains_any_of?(n.info_tab, @original_search_term) }
    @procedures_match_models = matching_nodes.select {|n| n.contains_any_of?(n.procedures_tab, @original_search_term) }
  end

end
