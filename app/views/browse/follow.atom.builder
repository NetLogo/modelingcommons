xml.instruct! 'xml-stylesheet', :href=>'/stylesheets/atom.css', :type=>'text/css'

xml.feed :xmlns=>'http://www.w3.org/2005/Atom' do
  xml.div :xmlns=>'http://www.w3.org/1999/xhtml', :class=>'info' do
    xml << <<-EOF
     This is an Atom formatted XML site feed.
     It is intended to be viewed in a Newsreader or syndicated to another site.
     Please visit <a href="http://www.atomenabled.org/">atomenabled.org</a> for more info.
   EOF
  end

  xml.title   "Activity in the model '#{@node.name}'"
  xml.link    :href=>url_for(:only_path=>false, :controller => 'account', :action=>'follow', :id => @node.id, :format => 'atom')
  xml.updated Time.now.iso8601
  xml.author  { xml.name 'Modeling Commons, CCL, Northwestern University' }

  @new_things.each do |thing|
    xml.entry do
      xml.title   thing[:description]
      xml.link    :href=>url_for(:only_path => false, :controller => 'browse', :action => 'one_model', :id => thing[:node_id])
      xml.id      Time.now
      xml.updated thing[:date]
      xml.author do
        @node.people.each do |person|
          xml.name person.fullname
        end
      end

      xml.summary do
        xml.div :xmlns=>'http://www.w3.org/1999/xhtml' do
          xml << thing[:title]
        end
      end
      xml.content do
        xml.div :xmlns=>'http://www.w3.org/1999/xhtml' do
          xml << "<h1>#{thing[:title]}</h1>"
          xml << "<p>#{thing[:contents]}</p>"
          xml << "<hr />"
          xml << "<p>This took place in the #{link_to 'Modeling Commons', :controller => :account, :action => :index}, where #{link_to 'NetLogo', 'http://ccl.northwestern.edu/netlogo'} modelers can share and collaboratively build models.  The Modeling Commons is written by Reuven M. Lerner, a PhD candidate in Learning Sciences at the #{link_to 'Center for Collaborative Learning and Computer-Based Modeling', 'http://ccl.northwestern.edu'} (directed by Uri Wilensky) at Northwestern University.</p>"
        end
      end
    end
  end

end
