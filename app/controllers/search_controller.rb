class SearchController < ApplicationController
  def search_action
    if params[:search_term].blank?
      flash[:notice] = "You must enter a search term in order to search."
      redirect_to :controller => :account, :action => :mypage
      return
    end

    logger.warn "[search_action] Now starting search_action"
    @original_search_term = params[:search_term]

    @models = Node.find(:all, :conditions => ["node_type_id = ? ", Node::MODEL_NODE_TYPE]).select {|m| m.name.downcase.index(@original_search_term.downcase)}

    @ferret_results = NodeVersion.find(:all, :conditions => "file_contents like '%#{@original_search_term}%'").map {|nv| nv.node}.uniq
    # @ferret_results = NodeVersion.find_with_ferret(@original_search_term, { :limit => :all}).map {|nv| nv.node}.uniq

    @info_match_models = @ferret_results.select { |r| r.info_tab.downcase.index(@original_search_term.downcase)}

    logger.warn "[search_action] Now checking @author_match_models"
    @author_match_models = Node.find(:all, :conditions => ["node_type_id = ? ", Node::MODEL_NODE_TYPE]).select {|m| m.people.map { |person| person.fullname}.join(" ").downcase.index(@original_search_term.downcase)}

    @procedures_match_models = @ferret_results.select { |r| r.procedures_tab.downcase.index(@original_search_term.downcase)}

    logger.warn "[search_action] Now checking @tag_match_models"
    @tag_match_models =
      Node.models.find_all {|m| m.tags.map { |t| t.name}.join(' ').downcase.index(@original_search_term.downcase)}
  end

end
