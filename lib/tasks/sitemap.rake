require 'hpricot'
require 'open-uri'
require 'builder'

namespace :sitemap do
  desc 'Generates sitemap.xml file in public directory'

  task :generate => :environment do

    # set domain to crawl
    DOMAIN = 'modelingcommons.org'
    BASE_URL = 'http://' + DOMAIN

    STDERR.puts "Now crawling from base URL '#{BASE_URL}'"

    # holds pages to go into map, and pages crawled
    @pages = []

    @pages = [ ]
    @pages += Tag.all.map { |t| "http://modelingcommons.org/tags/one_tag/#{t.id}"}
    @pages += Person.all.map { |person| "http://modelingcommons.org/?id=#{person.id}"}
    @pages += Project.all.map { |p| "http://modelingcommons.org/projects/#{p.id}"}

    Node.all.each do |node|
      next unless node.is_model?
      @pages << "http://modelingcommons.org/browse/one_model/#{node.id}"
      @pages << "http://modelingcommons.org/browse/one_model/#{node.id}"
      @pages << "http://modelingcommons.org/browse/browse_preview_tab/#{node.id}?tab=true"
      @pages << "http://modelingcommons.org/browse/browse_applet_tab/#{node.id}?tab=true"
      @pages << "http://modelingcommons.org/browse/browse_info_tab/#{node.id}?tab=true"
      @pages << "http://modelingcommons.org/browse/browse_procedures_tab/#{node.id}?tab=true"
      @pages << "http://modelingcommons.org/browse/browse_discuss_tab/#{node.id}?tab=true"
      @pages << "http://modelingcommons.org/browse/browse_history_tab/#{node.id}?tab=true"
      @pages << "http://modelingcommons.org/browse/browse_tags_tab/#{node.id}?tab=true"
      @pages << "http://modelingcommons.org/browse/browse_files_tab/#{node.id}?tab=true"
      @pages << "http://modelingcommons.org/browse/browse_related_tab/#{node.id}?tab=true"
      @pages << "http://modelingcommons.org/browse/download_model/#{node.id}"
    end

    @pages_crawled = @pages

    # start with home page
    crawl_for_links('/')

    # crawl each page in pages array unless it's already been crawled
    @pages.each {|page|
      crawl_for_links(page) unless @pages_crawled.include?(page)
    }

    # create xml for sitemap
    xml = Builder::XmlMarkup.new( :indent => 2 )
    xml.instruct!
    xml.comment! "Generated on: " + Time.now.to_s
    xml.urlset("xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9") {
      # loop through array of pages, and build sitemap.xml

      @pages.sort.each {|link|
        xml.url {
          if link.index(BASE_URL) == 0
            xml.loc link
          else
            xml.loc BASE_URL + link
          end

          # TODO - set changefreq
          #xml.changefreq 'monthly'
        }
      }
    }

    # convert builder xml to xml string, and save
    xml_string = xml.to_s.gsub("<to_s/>","")
    filename = RAILS_ROOT + "/public/sitemap.xml"
    xml_file = File.new(filename, "w")
    xml_file << xml_string
    xml_file.close

  end

  # end task, begin helper methods

  # uses Hpricot to grab links from a URI
  # adds uri to @pages_crawled
  # loops each link found
  # adds link to pages array if it should be included, unless it already exists
  def crawl_for_links(uri)
    if uri =~ /^http/
      url = uri
    else
      url = BASE_URL + uri
    end

    begin
      STDERR.puts "Opening URL '#{url}'"
      doc = Hpricot(open(url))
    rescue
      STDERR.puts "404 error for URI '#{url}'"
      return
    end
    @pages_crawled << uri
    (doc/"a").each do |a|
      if should_be_included?(a['href'])
        @pages << a['href'] unless(link_exists?(a['href'],@pages))
      end
    end
  end

  # returns true if any of the following are true:
  # - link isn't external (eg, contains 'http://') and doesn't contain 'mailto:'
  # - is equal to '/'
  # - link contains BASE_URL
  def should_be_included?(str)
    if ((!str.include?('http://') && !str.include?('mailto:')) || str == '/' || str.include?(BASE_URL))
      return true
    end
  end

  # checks each value in a given array for the given string
  # removes '/' character before comparison
  def link_exists?(str, array)
    array.detect{|l| strip_slashes(l) == strip_slashes(str)}
  end

  # removes '/' character from string
  def strip_slashes(str)
    str.gsub('/','')
  end

end
