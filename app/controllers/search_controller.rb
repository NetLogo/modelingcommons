# Controller to deal with search

class SearchController < ApplicationController

  def search_action
    if params[:search_term].blank?
      flash[:notice] = "You must enter a search term in order to search."
      redirect_to :controller => :account, :action => :mypage
      return
    end

    @original_search_term = params[:search_term].downcase

    @models =
      Node.all.select { |model| model.visible_to_user?(@person) and model.name.downcase.index(@original_search_term)}

    @author_match_models =
      Node.all.select {|model| model.visible_to_user?(@person) and model.people.map { |person| person.fullname}.join(" ").downcase.index(@original_search_term)}

    @tag_match_models =
      Node.all.select {|model| model.visible_to_user?(@person) and model.tags.map { |tag| tag.name}.join(' ').downcase.index(@original_search_term)}

    @procedures_match_models =
      Node.all.select {|model| model.visible_to_user?(@person) and model.procedures_tab.index(@original_search_term)}

  end


end
