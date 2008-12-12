class Node < ActiveRecord::Base
  MODEL_NODE_TYPE = 1
  PREVIEW_NODE_TYPE = 2
  DOCUMENT_NODE_TYPE = 3
  IMAGE_NODE_TYPE = 4
  DATA_NODE_TYPE = 5

  acts_as_tree :order => "name"

  belongs_to :node_type
  belongs_to :group

  belongs_to :visibility, :class_name => "PermissionSetting", :foreign_key => :visibility_id
  belongs_to :changeability, :class_name => "PermissionSetting", :foreign_key => :changeability_id

  has_many :node_versions, :order => 'updated_at DESC'
  has_many :postings, :order => 'updated_at'

  has_many :tagged_nodes
  has_many :tags, :through => :tagged_nodes

  validates_presence_of :name, :node_type_id, :visibility_id, :changeability_id
  validates_numericality_of :node_type_id, :visibility_id, :changeability_id

  # Convenience named scopes for grabbing certain types of children
  named_scope :models, :conditions => ['node_type_id = ? ', MODEL_NODE_TYPE]
  named_scope :non_models, :conditions => ['node_type_id <> ? ', MODEL_NODE_TYPE]
  named_scope :previews, :conditions => ['node_type_id = ? ', PREVIEW_NODE_TYPE]
  named_scope :documents, :conditions => ['node_type_id = ? ', DOCUMENT_NODE_TYPE]
  named_scope :images, :conditions => ['node_type_id = ? ', IMAGE_NODE_TYPE]
  named_scope :data, :conditions => ['node_type_id = ? ', DATA_NODE_TYPE]

  # ------------------------------------------------------------
  # Grab children of various sorts
  # ------------------------------------------------------------

  def children_of_id(id)
    self.children.select { |v| v.node_type_id == id}
  end

  def models
    self.children_of_id(MODEL_NODE_TYPE)
  end

  def non_models
    self.children.select { |v| v.node_type_id != MODEL_NODE_TYPE}
  end

  def previews
    self.children_of_id(PREVIEW_NODE_TYPE)
  end

  def latest_preview
    self.children.last.node_versions.sort { |n| n.created_at}.last.contents
  end

  def documents
    self.children_of_id(DOCUMENT_NODE_TYPE)
  end

  def images
    self.children_of_id(IMAGE_NODE_TYPE)
  end

  def data
    self.children_of_id(DATA_NODE_TYPE)
  end

  def files
    self.non_models
  end

  # ------------------------------------------------------------
  # Get the contents of a model file
  # ------------------------------------------------------------

  def is_model?
    return self.node_type_id == MODEL_NODE_TYPE
  end

  def people
    self.node_versions.map {|m| m.person}.uniq
  end

  def contents
    self.node_versions.sort_by {|nv| nv.created_at}.last.contents
  end

  def info_tab(with_html=false)
    text = self.node_versions.sort_by {|nv| nv.created_at }.last.info_tab

    if with_html
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

    text
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

  def gui_tab(with_html=false)
    text = self.node_versions.sort_by {|nv| nv.created_at}.last.gui_tab

    if with_html
      # Handle newlines
      text.gsub!("\n", "\n<br />")
    end

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

    self.contents.each do |line|

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

  def foo
    return 1
  end

end
