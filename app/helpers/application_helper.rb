# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def add_tag_link(name)
    link_to_function name do |page|
      page.insert_html :bottom, :tags, :partial => 'add_tag'
    end
  end

  def person_link(person)
    if person == @person
      link_to('You', :controller => :account, :action => :mypage, :id => person.id)
    else
      link_to(person.fullname, :controller => :account, :action => :mypage, :id => person.id)
    end

  end

  def model_link(node)
    link_to(node.name, :controller => :browse, :action => :one_model, :id => node.id)
  end

  def discuss_link(node, text)
    link_to(text, :controller => :browse, :action => :one_model, :id => node.id, :anchor => 'discuss-div')
  end

end
