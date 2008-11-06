module BrowseHelper
  def whats_new_text(item)

    if item.is_a?(Tag)
      "#{person_link(item.person)} created a new tag, #{link_to(item.name, :controller => :tags, :action => :one_tag, :id => item.id)}, #{distance_of_time_in_words(Time.now, item.created_at)} ago."

    elsif item.is_a?(TaggedNode)
      "#{person_link(item.person)} applied the tag #{link_to(item.tag.name, :controller => :tags, :action => :one_tag, :id => item.tag.id)} to the model #{model_link(item.node)}, #{distance_of_time_in_words(Time.now, item.created_at)} ago."

    elsif item.is_a?(Node)
      "The model #{link_to(item.name, :controller => :browse, :action => :one_model, :id => item.id)} was updated by #{person_link(item.node_versions.sort_by { |nv| nv.updated_at}.reverse.first.person)} #{distance_of_time_in_words(Time.now, item.created_at)} ago."

    elsif item.is_a?(Posting)
      question_type = item.is_question? ? 'question' : 'comment'

      "#{person_link(item.person)} posted a #{discuss_link(item, question_type)} about #{link_to(item.node.name, :controller => :browse, :action => :one_model, :id => item.node.id)} #{distance_of_time_in_words(Time.now, item.created_at)} ago."

    elsif item.is_a?(Person)
      "#{person_link(item)} registered on the Modeling Commons #{distance_of_time_in_words(Time.now, item.created_at)}.  Welcome, #{item.first_name}!"

    else
      "#{item.class.to_s}, #{distance_of_time_in_words(Time.now, item.created_at)} ago"
    end

  end
end
