# Model for an individual node in our graph

class Node < ActiveRecord::Base
  acts_as_tree :order => "name"

  belongs_to :group

  belongs_to :visibility, :class_name => "PermissionSetting", :foreign_key => :visibility_id
  belongs_to :changeability, :class_name => "PermissionSetting", :foreign_key => :changeability_id

  has_many :postings, :order => 'updated_at'
  has_many :active_postings, :class_name => "Posting", :conditions => "deleted_at is null", :order => 'updated_at'

  has_many :tagged_nodes
  has_many :tags, :through => :tagged_nodes

  has_many :email_recommendations
  has_many :recommendations
  has_many :spam_warnings

  has_many :logged_actions

  has_many :node_projects
  has_many :projects, :through => :node_projects

  validates_presence_of :name, :visibility_id, :changeability_id
  validates_numericality_of :visibility_id, :changeability_id

  default_scope :order => 'name ASC', :include => [:visibility, :changeability, :tags, :group]

  named_scope :created_since, lambda { |since| { :conditions => ['created_at >= ? ', since] }}
  named_scope :updated_since, lambda { |since| { :conditions => ['updated_at >= ? ', since] }}

  # ------------------------------------------------------------
  # Grab children of various sorts
  # ------------------------------------------------------------

  def node_versions
    NodeVersion.all(:conditions => { :node_id => id}, :order => :created_at.desc )
  end

  def current_version
    node_versions.first
  end

  # Create methods for the different attachment types
  NodeAttachment::TYPES.keys.each do |attachment_type|

    define_method(attachment_type.to_sym) do
      NodeAttachment.first(:conditions => { :type => attachment_type, :node_id => id},
                           :order => 'created_at DESC')
    end

    define_method("#{attachment_type}s".to_sym) do
      NodeAttachment.all(:conditions => { :type => attachment_type, :node_id => id},
                         :order => 'created_at DESC')
    end
  end

  def attachments
    NodeAttachment.all(:conditions => { :node_id => id})
  end

  # ------------------------------------------------------------
  # Info from the latest version
  # ------------------------------------------------------------

  def description
    @description ||= current_version.description
  end

  def person
    current_version.person
  end

  def most_recent_author
    @most_recent_author ||= person
  end

  def people
    @model_people ||= node_versions.map {|version| version.person}.uniq
  end

  def author?(person)
    people.member?(person)
  end

  # ------------------------------------------------------------
  # Get the contents of a model file
  # ------------------------------------------------------------

  def contents
    @contents ||= current_version.contents
  end

  def netlogo_version
    @netlogo_version ||= current_version.netlogo_version
  end

  def netlogo_version_for_applet
    applet_directory = "#{RAILS_ROOT}/public/applet/"

    [netlogo_version,
     netlogo_version.gsub(/RC\d+$/, ''),
     netlogo_version.gsub(/pre.*$/, ''),
     netlogo_version.gsub(/beta.*$/, ''),
     netlogo_version.gsub(/^(\d+\.\d+).*/, '\1'),
     Dir.entries(applet_directory).grep(/^\d+\.\d+$/).sort.last].each do |version|

      return version if File.exists?("#{applet_directory}/#{version}")
    end
  end

  def applet_class
    applet_jar_version = netlogo_version_for_applet

    if applet_jar_version.to_f < 4.1
      "org.nlogo.window.Applet"
    elsif ["4.1pre4", "4.1pre5", "4.1pre6", "4.1pre7", "4.1pre8", "4.1pre9"].member?(netlogo_version)
      "org.nlogo.applet.Applet"
    else
      "org.nlogo.lite.Applet"
    end
  end

  def info_tab
    current_version.info_tab || "Info tab is empty."
  end

  def info_tab_html
    text = info_tab

    # Handle headlines
    text.gsub! /([-_.?A-Z ]+)\n-+/ do
      "<h3>#{$1}</h3>"
    end

    # Handle URLs
    text.gsub! /(http:\/\/[-\/_.~\w]+\w)/ do
      "<a target=\"_blank\" href=\"#{$1}\">#{$1}</a>"
    end

    # Handle newlines
    text.gsub!("\n", "</p>\n<p>")
  end

  def procedures_tab()
    current_version.procedures_tab || "Procedures tab is empty."
  end

  def procedures_tab_html
    text = procedures_tab

    # Italicize comments
    text.gsub! /(;.*)\n/ do
      "<span class=\"proc-comment\">#{$1}</span>\n"
    end

    # Make "to" and "to-report" stand out
    text.gsub! /^\s*(to(-report)?) / do
      "<span class=\"proc-to\">#{$1}</span> "
    end

    # Make "end" stand out
    text.gsub! /^\s*end\b/ do
      "<span class=\"proc-end\">end</span><br /> "
    end

    # Handle newlines
    text.gsub!("\n", "\n<br />")

    "<tt>#{text}</tt>"
  end

  def filename
    name.gsub('/', '_').gsub(' ', '_')
  end

  def dimensions

    # This algorithm is really horrible and nasty.  It was taken
    # almost precisely from the Perl code in model.cgi, on
    # ccl.northwestern.edu.  I have a feeling that I could clean it up
    # a lot, but that'll take a bit of time, so I'll just keep it this
    # way for now.

    dividers = 0
    getdimens = -1
    gotfirstdimens = 0
    width = 0
    height = 0

    contents.each do |line|

      # Handle dividers
      if line =~ /\@\#\$\#\@\#\$\#\@/
          dividers = dividers + 1

        if (dividers == 1) and (gotfirstdimens == 0)
          getdimens = 0
          gotfirstdimens = 1
        end

        next
      end

      # Handle whitespace
      if line =~ /^\s*$/ and dividers == 1
        getdimens = 0
        next
      end

      # Handle dimensions
      if line =~ /CC-WINDOW/
        getdimens = -1
      end

      if getdimens >= 0

        if (getdimens == 3 and line.to_i >= width and line =~ /^\d+/)
          width = line.to_i
        end

        if (getdimens == 4 and line.to_i >= height and line =~ /^\d+/)
          height = line.to_i
        end

        getdimens = getdimens + 1
      end
    end

    # Height buffer
    height = height + 31

    # Width buffer
    width = width + 31

    { :height => height, :width => width}
  end

  def can_be_read_by?(person)
    author?(person)
  end

  def download_name
    name.gsub(/[\s\/]/, '_')
  end

  def zipfile_name
    "#{download_name}.zip"
  end

  def zipfile_name_full_path
    "#{RAILS_ROOT}/public/modelzips/#{zipfile_name}"
  end

  def world_visible?
    visibility.short_form == 'a'
  end

  def author_visible?
    visibility.short_form == 'u'
  end

  def group_visible?
    visibility.short_form == 'g'
  end

  def visible_to_user?(person)
    # If everyone can see this model, then deal with the simple case
    return true if world_visible?

    # If only the author can see this model, then allow anyone who has
    # contributed to the model to see it
    return true if author?(person)

    # If only the group can see this model, then check if the user is logged in
    # and a member of the group
    return true if group and group_visible? and group.approved_members.member?(person)

    # If the user is an administrator, then let them see the model
    return true if person and person.administrator?

    return false
  end

  def changeable_by_user?(person)
    return false if person.nil?

    return true if author?(person)

    return true if group and group_changeable? and group.approved_members.member?(person)

    return false
  end

  def world_changeable?
    changeability.short_form == 'a'
  end

  def author_changeable?
    changeability.short_form == 'u'
  end

  def group_changeable?
    changeability.short_form == 'g'
  end

  def cannot_be_run_as_applet?
    return true if name =~ /3D/
    return true if procedures_tab =~ /hubnet-/
  end

  def self.search(search_term, person)
    find(:all,
         :conditions => [ "position( ? in lower(name) ) > 0 ", search_term],
         :include => :visibility).select { |node| node.visible_to_user?(person)}
  end

  def create_zipfile
    Zip::ZipOutputStream::open(zipfile_name_full_path) do |io|
      io.put_next_entry("#{download_name}.nlogo")
      io.write(contents.to_s)

      attachments.each do |attachment|
        io.put_next_entry("#{attachment.filename}")
        io.write(attachment.contents.to_s)
      end
    end

    zipfile_name_full_path
  end

end
