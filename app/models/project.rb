# Model to keep track of projects (i.e., collections of models)
require 'RMagick'


class Project < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name

  has_many :node_projects
  has_many :nodes, :through => :node_projects

  belongs_to :person

  default_scope :order => 'lower(name) ASC'
  
  after_save :create_project_image
  
  def create_project_image
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
        image.resize_to_fill!(60, 60, Magick::CenterGravity)
      end
      
      m = list.montage {
        self.geometry = '60x60+0+0'
        self.tile = '2x2'
      } .first
    elsif list.length == 3
      list[0..1].each { |image|
        image.resize_to_fill!(60, 60, Magick::CenterGravity)
      }
      top = list[0..1].montage {
        self.geometry = '60x60+0+0'
        self.tile = '2x1'
      } .first
      
      bottom = list[2]
      bottom.resize_to_fill!(120, 60, Magick::CenterGravity)
      list = Magick::ImageList.new
      list.push(top)
      list.push(bottom)
      
      m = list.montage {
        self.geometry = '120x60+0+0'
        self.tile = '1x2'
      } .first
    elsif list.length == 2
      list.each do |image| 
        image.resize_to_fill!(120, 60, Magick::CenterGravity)
      end
      
      m = list.montage {
        self.geometry = '120x60+0+0'
        self.tile = '1x2'
      } .first
    elsif list.length == 1
      m = list.first.resize_to_fill!(120, 120, Magick::CenterGravity)
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
  
end
