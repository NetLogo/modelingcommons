# Model to keep track of projects (i.e., collections of models)

class Project < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name

  has_many :node_projects
  has_many :nodes, :through => :node_projects

  belongs_to :person

  default_scope :order => 'lower(name) ASC'
  
  after_save :create_project_image
  
  def create_project_image
    size = 152
    list = Magick::ImageList.new
    if self.nodes.length > 0
      id=self.nodes.fetch(0).id
      self.nodes.each do |model| 
        if !model.preview.blank?
          list.from_blob(model.preview.contents.to_s)
        end
        if list.length  >= 4
          break
        end
      end
    end
    if list.length == 4
      list.each do |image| 
        image.resize_to_fill!(size/2, size/2, Magick::CenterGravity)
      end
      
      m = list.montage {
        self.geometry = "#{size/2}x#{size/2}+0+0"
        self.tile = '2x2'
      } .first
    elsif list.length == 3
      list[0..1].each { |image|
        image.resize_to_fill!(size/2, size/2, Magick::CenterGravity)
      }
      top = list[0..1].montage {
        self.geometry = "#{size/2}x#{size/2}+0+0"
        self.tile = '2x1'
      } .first
      
      bottom = list[2]
      bottom.resize_to_fill!(size, size/2, Magick::CenterGravity)
      list = Magick::ImageList.new
      list.push(top)
      list.push(bottom)
      
      m = list.montage {
        self.geometry = "#{size}x#{size/2}+0+0"
        self.tile = '1x2'
      } .first
    elsif list.length == 2
      list.each do |image| 
        image.resize_to_fill!(size, size/2, Magick::CenterGravity)
      end
      
      m = list.montage {
        self.geometry = "#{size}x#{size/2}+0+0"
        self.tile = '1x2'
      } .first
    elsif list.length == 1
      m = list.first.resize_to_fill!(size, size, Magick::CenterGravity)
    else
      m = Magick::Image.new(1,1) {
        self.background_color = 'rgb(230, 230, 230)'
      }
    end
    
    m.format = 'png'
    dir = RAILS_ROOT + "/public/system/project_images/" + self.id.to_s + "/"
    Dir.mkdir(dir) if !File.exists?(dir)
    m.write(dir + "project.png")
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

  def create_zipfile
    Zippy.create zipfile_name_full_path do |io|

      nodes.each do |node|

        io["#{download_name}/#{node.download_name}/#{download_name}.nlogo"] = node.contents.to_s

        node.attachments.each do |attachment|
          io["#{download_name}/#{node.download_name}/#{attachment.filename}"] = attachment.contents.to_s
        end
      end
    end

    zipfile_name_full_path
  end

end
