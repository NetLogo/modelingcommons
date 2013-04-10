# Model to store and track social tags

class Tag < ActiveRecord::Base
  belongs_to :person

  has_many :tagged_nodes
  has_many :nodes, :through => :tagged_nodes

  validates_presence_of :name, :person_id
  validates_uniqueness_of :name, :case_sensitive => false

  scope :created_since, lambda { |since| { :conditions => ['created_at >= ? ', since] }}

  def people
    return self.nodes.map {|model| model.person}.uniq
  end

  def self.search(term)
    all(:conditions => [ "position( ? in lower(name) ) > 0 ", term])
  end

  def to_s
    name
  end

  def download_name
    name.gsub(/[\s\/]/, '_')
  end

  def zipfile_name
    "#{download_name}.zip"
  end

  def zipfile_name_full_path
    "#{Rails.root}/public/modelzips/#{zipfile_name}"
  end

  def create_zipfile(web_user)
    Zippy.create zipfile_name_full_path do |io|

      nodes.each do |node|
        next unless node.visible_to_user?(web_user)

        io["#{download_name}/#{node.download_name}/#{download_name}.nlogo"] = node.contents.to_s

        node.attachments.each do |attachment|
          io["#{download_name}/#{node.download_name}/#{attachment.filename}"] = attachment.contents.to_s
        end
      end
    end

    zipfile_name_full_path
  end
end
