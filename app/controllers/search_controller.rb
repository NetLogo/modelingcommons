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
                ).select { |model| model.name.downcase.index(@original_search_term)}

    @author_match_models =
      Node.find(:all,
                :conditions => ["node_type_id = ? ",
                                Node::MODEL_NODE_TYPE]
                ).select {|model| model.people.map { |person| person.fullname}.join(" ").downcase.index(@original_search_term)}

    @tag_match_models =
      Node.models.find_all {|model| model.tags.map { |tag| tag.name}.join(' ').downcase.index(@original_search_term)}
  end

end
