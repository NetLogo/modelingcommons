xml.instruct! 'xml-stylesheet', :href=>'/stylesheets/atom.css', :type=>'text/css'

xml.feed :xmlns=>'http://www.w3.org/2005/Atom' do
  xml.div :xmlns=>'http://www.w3.org/1999/xhtml', :class=>'info' do
    xml << <<-EOF
     This is an Atom formatted XML site feed.
     It is intended to be viewed in a Newsreader or syndicated to another site.
     Please visit <a href="http://www.atomenabled.org/">atomenabled.org</a> for more info.
   EOF
  end

  xml.title   "Uses of the '#{@tag.name}' tag"
  xml.link    :rel=>'self',
  :href=>url_for(:only_path=>false, :action=>'posts', :path=>['index.atom'])
  xml.link    :href=>url_for(:action=>'posts', :path=>nil)
  xml.id      :href=>url_for(:only_path=>false, :action=>'posts', :path=>nil)
  xml.updated Time.now.iso8601
  xml.author  { xml.name 'Modeling Commons, CCL, Northwestern University' }

  @tagged_nodes.each do |entry|
    xml.entry do
      xml.title
      xml.link    :href=>url_for(entry.id.to_s)
      xml.id      Time.now
      xml.updated entry.updated_at
      xml.author  { xml.name entry.person.fullname } if entry.person
      xml.summary do
        xml.div :xmlns=>'http://www.w3.org/1999/xhtml' do
          xml << "<p>#{link_to entry.person.fullname, :controller => :account, :action => :mypage, :id => entry.person.id} tagged the #{link_to entry.node.name, :controller => :browse, :action => :one_model, :id => entry.node.id} model on #{entry.updated_at}, or #{distance_of_time_in_words(Time.now, entry.updated_at)} ago.</p>"
        end
      end
      xml.content do
        xml.div :xmlns=>'http://www.w3.org/1999/xhtml' do
          xml << "<p>#{link_to entry.person.fullname, :controller => :account, :action => :mypage, :id => entry.person.id} tagged the #{link_to entry.node.name, :controller => :browse, :action => :one_model, :id => entry.node.id} model on #{entry.updated_at}, or #{distance_of_time_in_words(Time.now, entry.updated_at)} ago.</p>"
          xml << "<p>#{entry.person.first_name} commented '#{entry.comment}' upon applying this tag.</p>"
          xml << "<p>This took place in the #{link_to 'Modeling Commons', :controller => :account, :action => :index}, where #{link_to 'NetLogo', 'http://ccl.northwestern.edu/netlogo'} modelers can share and collaboratively build models.  The Modeling Commons is written by Reuven M. Lerner, a PhD candidate in Learning Sciences at the #{link_to 'Center for Collaborative Learning and Computer-Based Modeling', 'http://ccl.northwestern.edu'} (directed by Uri Wilensky) at Northwestern University.</p>"
        end
      end
    end
  end

end
