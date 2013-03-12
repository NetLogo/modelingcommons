# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def whats_new_model(node)
    
    now = Time.now
    time_since_update = distance_of_time_in_words(Time.now, node.updated_at)
    link_to_item_person = person_link(node.person)
    original_node_author = NodeVersion.fields(:person_id).all(:conditions => {:node_id => node.id},
                                                              :order => :created_at.desc
                                                             ).first.person           
    this_user_did_it = true if original_node_author == @person
    updated_or_created = (node.created_at.to_i == node.updated_at.to_i ? 'created' : 'updated')
    link = url_for(:controller => "browse", :action => "one_model", :id => node.id)
    
    if !node.previews.nil? and !node.previews.empty?
      image = url_for :controller => :browse, :action => :display_preview, :id => node.id
    end  
    
    
    {
      :time => "#{time_since_update} ago", 
      :action => "#{person_link(original_node_author)} #{updated_or_created} model", 
      :your_news => this_user_did_it,
      :image => image,
      :name => node.name,
      :link => link
    }
  end
  
  def whats_new_tag(item)
    this_user_did_it = true if item.person == @person
    now = Time.now
    time_since_update = distance_of_time_in_words(Time.now, item.updated_at)
    link_to_item_person = person_link(item.person)
    
    if item.is_a?(Tag)
      action = "#{link_to_item_person} created tag"
      link = url_for(:controller => :tags, :action => :one_tag, :id => item.id)
      name = item.name
    elsif item.is_a?(TaggedNode)
      action = "#{link_to_item_person} added tag #{link_to(item.tag.name, :controller => :tags, :action => :one_tag, :id => item.tag.id)} to"
      link = url_for(:controller => "browse", :action => "one_model", :id => item.node.id)
      name = item.node.name
      if !item.node.previews.nil? and !item.node.previews.empty?
        image = url_for :controller => :browse, :action => :display_preview, :id => item.node.id
      end
    end
    
    {
      :time => "#{time_since_update} ago", 
      :action => action, 
      :your_news => this_user_did_it,
      :link => link,
      :name => name,
      :image => image
    }
  end
  
  def whats_new_comment(comment)
    this_user_did_it = true if comment.person == @person
    now = Time.now
    time_since_update = distance_of_time_in_words(Time.now, comment.updated_at)
    link_to_item_person = person_link(comment.person)
    url_for_model = url_for(:controller => "browse", :action => "one_model", :id => comment.node.id)
    link = url_for(:controller => "browse", :action => "one_model", :id => comment.node.id, :anchor => "model_tabs_browse_discuss")
    model_name = comment.node.name
    name = "\"" + comment.title + "\""
    
    if comment.is_question?
      action = "#{link_to_item_person} asked a question about model <a href=\"#{url_for_model}\">#{model_name}</a>"
    else 
      action = "#{link_to_item_person} commented on model <a href=\"#{url_for_model}\">#{model_name}</a>"
    end

    if !comment.node.previews.nil? and !comment.node.previews.empty?
      image = url_for :controller => :browse, :action => :display_preview, :id => comment.node.id
    end
    
    {
      :time => "#{time_since_update} ago", 
      :action => action, 
      :your_news => this_user_did_it,
      :link => link,
      :name => name,
      :image => image,
      :person_image => comment.person.avatar.url(:thumb)
    }
  end
  
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
      original_node_author = 
        NodeVersion.fields(:person_id).all(:conditions => {:node_id => item.id},
                                           :order => :created_at.desc).first.person
      this_user_did_it = true if original_node_author == @person

      updated_or_created = (item.created_at.to_i == item.updated_at.to_i ? 'created' : 'updated')
                            
      output << "#{model_link(item)} was #{updated_or_created} by #{person_link(original_node_author)} #{time_since_update} 

ago."

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

  def person_image(person, size=:thumb)
    if ![:thumb, :medium, :original].include?(size)
      size=:thumb
    end
    image_tag(person.avatar.url(size))
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
  
  def person_url(person)
    if person.nil?
      url_for(:controller => :account, :action => :mypage)
    elsif person == @person
      url_for(:controller => :account, :action => :mypage, :id => person.id)
    else
      url_for(:controller => :account, :action => :mypage, :id => person.id)
    end
  end

  def group_link(group)
    link_to(group.name, :controller => :membership, :action => :one_group, :id => group.id)
  end

  def tag_link(tag)
    link_to(tag.name, :controller => :tags, :action => :one_tag, :id => tag.id)
  end

  def model_link(node)
    link_to(model_image(node) + node.name, model_url(node), {:class => 'model_link'})
  end
  
  def model_image(node)
    if !node.previews.empty?
      image_tag(url_for(:controller => :browse, :action => :display_preview, :id => node.id), :alt => node.name + " preview image")
    else
      ''
    end
  end
  def model_url(node)
    url_for(:controller => :browse, :action => :one_model, :id => node.id)
  end
  def discuss_link(node, text)
    link_to(text, :controller => :browse, :action => :one_model, :id => node.id, :anchor => 'discuss')
  end
  
  def project_link(project)
    link_to(project.name, project_url(project))
  end
  def project_url(project)
    url_for(:controller => :projects, :action => :show, :id => project.id)
  end
  def project_image(project)
    image_tag("/system/project_images/#{project.id.to_s}/project.png", :alt => project.name)
  end
  def html_string_truncate(string, length)
    if string.length > length
      string = string[0..length-2] << "&hellip;"
    end
    string
  end
end
