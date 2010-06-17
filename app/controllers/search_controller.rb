# Controller to deal with search

class SearchController < ApplicationController

  def search_action
    if params[:search_term].blank?
      flash[:notice] = "You must enter a search term in order to search."
      redirect_to :controller => :account, :action => :mypage
      return
    end

    @original_search_term = params[:search_term].downcase

    @viewable_models = Node.all.select { |model| model.visible_to_user?(@person)}

    @models = @viewable_models.select { |model| model.name.downcase.index(@original_search_term)}

    @author_match_models =
      @viewable_models.select { |model| model.people.map { |person| person.fullname}.join(" ").downcase.index(@original_search_term)}

    @tag_match_models =
      @viewable_models.select { |model| model.tags.map { |tag| tag.name}.join(' ').downcase.index(@original_search_term)}

    @info_match_models =
      @viewable_models.select { |model| model.current_version.info_keyword_index.member?(@original_search_term)}

    @procedures_match_models =
      @viewable_models.select { |model| model.current_version.procedures_keyword_index.member?(@original_search_term)}

  end


end
