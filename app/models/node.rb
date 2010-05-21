class Node < ActiveRecord::Base
  MODEL_NODE_TYPE = 1
  PREVIEW_NODE_TYPE = 2
  PDF_NODE_TYPE = 3
  IMAGE_NODE_TYPE = 4
  DATA_NODE_TYPE = 5
  EXTENSION_NODE_TYPE = 6
  WORD_NODE_TYPE = 7
  POWERPOINT_NODE_TYPE = 8
  APPLET_HTML_NODE_TYPE = 9

  acts_as_tree :order => "name"

  belongs_to :node_type
  belongs_to :group

  belongs_to :visibility, :class_name => "PermissionSetting", :foreign_key => :visibility_id
  belongs_to :changeability, :class_name => "PermissionSetting", :foreign_key => :changeability_id

  has_many :node_versions, :order => 'updated_at DESC'
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

  validates_presence_of :name, :node_type_id, :visibility_id, :changeability_id
  validates_numericality_of :node_type_id, :visibility_id, :changeability_id

  # Convenience named scopes for grabbing certain types of children
  named_scope :models, :conditions => ['node_type_id = ? ', MODEL_NODE_TYPE]
  named_scope :non_models, :conditions => ['node_type_id <> ? ', MODEL_NODE_TYPE]
  named_scope :previews, :conditions => ['node_type_id = ? ', PREVIEW_NODE_TYPE]
  named_scope :pdfs, :conditions => ['node_type_id = ? ', PDF_NODE_TYPE]
  named_scope :images, :conditions => ['node_type_id = ? ', IMAGE_NODE_TYPE]
  named_scope :data, :conditions => ['node_type_id = ? ', DATA_NODE_TYPE]
  named_scope :extensions, :conditions => ['node_type_id = ? ', EXTENSION_NODE_TYPE]
  named_scope :word_docs, :conditions => ['node_type_id = ? ', WORD_NODE_TYPE]
  named_scope :powerpoint_docs, :conditions => ['node_type_id = ? ', POWERPOINT_NODE_TYPE]
  named_scope :applet_htmls, :conditions => ['node_type_id = ? ', APPLET_HTML_NODE_TYPE]

  # ------------------------------------------------------------
  # Grab children of various sorts
  # ------------------------------------------------------------

  def person
    self.node_versions.sort { |n| n.created_at}.last.person
  end

  def children_of_type(id)
    self.children.select { |version| version.node_type_id == id}
  end

  def models
    self.children_of_type(MODEL_NODE_TYPE)
  end

  def non_models
    self.children.select { |version| version.node_type_id != MODEL_NODE_TYPE}
  end

  def previews
    if self.children_of_type(PREVIEW_NODE_TYPE).empty?
      [ ]
    else
      self.children_of_type(PREVIEW_NODE_TYPE)[0].node_versions.sort_by { |nv| nv.created_at}
    end
  end

  def latest_preview
    return nil if self.previews.empty?
    self.previews.last.file_contents
  end

  def applet_htmls
    self.children_of_type(APPLET_HTML_NODE_TYPE)
  end

  def applet_html
    if self.applet_htmls.empty?
      nil
    else
      self.applet_htmls.last.file_contents
    end
  end

  def documents
    self.children_of_type(DOCUMENT_NODE_TYPE)
  end

  def images
    self.children_of_type(IMAGE_NODE_TYPE)
  end

  def data
    self.children_of_type(DATA_NODE_TYPE)
  end

  def files
    self.non_models
  end

  # ------------------------------------------------------------
  # Info from the latest version
  # ------------------------------------------------------------

  def description
    self.node_versions.sort_by {|nv| nv.created_at}.last.description
  end

  def most_recent_author
    self.node_versions.sort_by {|nv| nv.created_at}.last.person
  end

  def mime_type
    self.node_type.mime_type
  end

  # ------------------------------------------------------------
  # Get the contents of a model file
  # ------------------------------------------------------------

  def is_model?
    return self.node_type_id == MODEL_NODE_TYPE
  end

  def is_preview?
    return self.node_type_id == PREVIEW_NODE_TYPE
  end

  def people
    self.node_versions.map {|version| version.person}.uniq
  end

  def file_contents
    self.node_versions.sort_by {|version| version.created_at}.last.file_contents
  end

  def netlogo_version
    self.node_versions.sort_by {|version| version.created_at}.last.netlogo_version
  end

  def netlogo_version_for_applet
    applet_directory = "#{RAILS_ROOT}/public/applet/"

    [netlogo_version,
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

  def info_tab(with_html=false)
    text = self.node_versions.sort_by {|nv| nv.created_at }.last.info_tab

    if text.blank?
      "Info tab is empty."

    elsif with_html
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
  end

  def procedures_tab(with_html=false)
    text = self.node_versions.sort_by {|nv| nv.created_at}.last.procedures_tab

    if with_html
      # Italicize comments
      text.gsub! /(;.*)\n/ do
        "<span class=\"proc-comment\">#{$1}</span>\n"
      end

      # Make "to" and "end" stand out
      text.gsub! /^\s*to / do
        "<span class=\"proc-to\">to</span> "
      end

      # Make "to" and "end" stand out
      text.gsub! /^\s*end\b/ do
        "<span class=\"proc-end\">end</span><br /> "
      end

      # Handle newlines
      text.gsub!("\n", "\n<br />")
    end

    text = "<tt>#{text}</tt>"

    text
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

    self.file_contents.each do |line|

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
    people.member?(person)
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

end
