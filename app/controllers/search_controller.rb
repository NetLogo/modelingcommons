class SearchController < ApplicationController
  def search_action
    if params[:search_term].blank?
      flash[:notice] = "You must enter a search term in order to search."
      redirect_to :controller => :account, :action => :mypage
      return
    end

    @original_search_term = params[:search_term].downcase

    @models =
      Node.find(:all,
                :conditions => ["node_type_id = ? ",
                                Node::MODEL_NODE_TYPE]
                ).select { |m| m.name.downcase.index(@original_search_term)}

    @author_match_models =
      Node.find(:all,
                :conditions => ["node_type_id = ? ",
                                Node::MODEL_NODE_TYPE]
                ).select {|m| m.people.map { |person| person.fullname}.join(" ").downcase.index(@original_search_term)}

    @tag_match_models =
      Node.models.find_all {|m| m.tags.map { |t| t.name}.join(' ').downcase.index(@original_search_term)}
  end

end
