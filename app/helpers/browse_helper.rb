module BrowseHelper
  def whats_new_text(item)

    this_user_did_it = false
    output = ''

    if item.is_a?(Tag)
      this_user_did_it = true if item.person == @person

      output << "#{person_link(item.person)} created a new tag, #{link_to(item.name, :controller => :tags, :action => :one_tag, :id => item.id)}, #{distance_of_time_in_words(Time.now, item.created_at)} ago."

    elsif item.is_a?(TaggedNode)
      this_user_did_it = true if item.person == @person

      output << "#{person_link(item.person)} applied the tag #{link_to(item.tag.name, :controller => :tags, :action => :one_tag, :id => item.tag.id)} to the model #{model_link(item.node)}, #{distance_of_time_in_words(Time.now, item.created_at)} ago."

    elsif item.is_a?(Node)
      original_node_author = item.node_versions.sort_by { |nv| nv.updated_at}.reverse.first.person
      this_user_did_it = true if original_node_author == @person

      output << "The model #{link_to(item.name, :controller => :browse, :action => :one_model, :id => item.id)} was updated by #{person_link(original_node_author)} #{distance_of_time_in_words(Time.now, item.created_at)} ago."

    elsif item.is_a?(Posting)
      this_user_did_it = true if item.person == @person

      question_type = item.is_question? ? 'question' : 'comment'

      output << "#{person_link(item.person)} posted a #{discuss_link(item.node, question_type)} about #{link_to(item.node.name, :controller => :browse, :action => :one_model, :id => item.node.id)} #{distance_of_time_in_words(Time.now, item.created_at)} ago."

    elsif item.is_a?(Person)
      this_user_did_it = true if item.person == @person

      output << "#{person_link(item)} joined the Modeling Commons #{distance_of_time_in_words(Time.now, item.created_at)} ago.  Welcome, #{item.first_name}!"

    else
      output << "#{item.class.to_s}, #{distance_of_time_in_words(Time.now, item.created_at)} ago"
    end

    if this_user_did_it
      output = "<span class=\"highlight\"#{output}</span>"
    end

    output
  end
end
