# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def whats_new_text(item)

    this_user_did_it = true if item.person == @person
    output = ''

    now = Time.now
    time_since_update = distance_of_time_in_words(Time.now, item.updated_at)
    link_to_item_person = person_link(item.person)

    if item.is_a?(Tag)
      output << "#{link_to_item_person} created a new tag, #{link_to(item.name, :controller => :tags, :action => :one_tag, :id => item.id)}, #{time_since_update} ago."

    elsif item.is_a?(TaggedNode)
      output << "#{model_link(item.node)} was tagged #{link_to(item.tag.name, :controller => :tags, :action => :one_tag, :id => item.tag.id)} by #{link_to_item_person}, #{time_since_update} ago."

    elsif item.is_a?(Node)
      next unless item.node_versions
      logger.warn "[ApplicationHelper#whats_new_text] Now looking at Node '#{item.id}'"
      original_node_author = item.node_versions.sort_by { |nv| nv.updated_at}.reverse.first.person
      this_user_did_it = true if original_node_author == @person

      output << "#{model_link(item)} was updated by #{person_link(original_node_author)} #{time_since_update} ago."

    elsif item.is_a?(Posting)
      question_type = item.is_question? ? 'question' : 'comment'

      output << "#{person_image(item.person)} #{link_to_item_person} posted a #{discuss_link(item.node, question_type)} about #{link_to(item.node.name, :controller => :browse, :action => :one_model, :id => item.node.id)} #{time_since_update} ago."

    elsif item.is_a?(Person)
      output << "#{person_link(item)} joined the Modeling Commons #{time_since_update} ago.  Welcome, #{item.first_name}!"

    else
      output << "#{item.class.to_s}, #{time_since_update} ago"
    end

    if this_user_did_it
      output = "<span class=\"highlight\">#{output}</span>"
    end

    output
  end

  def add_tag_link(name)
    link_to_function name, { :id => 'add_tag_link'} do |page|
      page.insert_html :bottom, :new_tags, :partial => 'add_tag'
      page << "$('.complete').autocomplete('/tags/complete_tags');"
    end
  end

  def person_image(person)
    image_tag(person.avatar.url(:thumb))
  end

  def person_link(person)
    if person.nil?
      "(No person)"
    elsif person == @person
      link_to('You', :controller => :account, :action => :mypage, :id => person.id)
    else
      link_to(person.fullname, :controller => :account, :action => :mypage, :id => person.id)
    end
  end

  def group_link(group)
    link_to(group.name, :controller => :membership, :action => :one_group, :id => group.id)
  end

  def tag_link(tag)
    link_to(tag.name, :controller => :tags, :action => :one_tag, :id => tag.id)
  end

  def model_link(node)
    if !node.previews.empty?
      image_tag_output = image_tag("/browse/display_preview/" + node.id.to_s, :width => "30",  :height => "30", :alt => "Preview image")
    else
      image_tag_output = ''
    end

    link_to_output = link_to(node.name, :controller => "browse", :action => "one_model", :id => node.id)
    "#{image_tag_output} #{link_to_output}"
  end

  def discuss_link(node, text)
    link_to(text, :controller => :browse, :action => :one_model, :id => node.id, :anchor => 'discuss')
  end

end
