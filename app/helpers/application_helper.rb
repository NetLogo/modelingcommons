# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def add_tag_link(name)
    link_to_function name do |page|
      page.insert_html :bottom, :tags, :partial => 'add_tag'
    end
  end
end
