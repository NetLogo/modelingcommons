# Model to store and track social tags

class Tag < ActiveRecord::Base
  belongs_to :person

  has_many :tagged_nodes
  has_many :nodes, :through => :tagged_nodes

  validates_presence_of :name, :person_id
  validates_uniqueness_of :name, :case_sensitive => false

  named_scope :created_since, lambda { |since| { :conditions => ['created_at >= ? ', since] }}

  def people
    return self.nodes.map {|model| model.person}.uniq
  end

  def self.search(term)
    all(:conditions => [ "position( ? in lower(name) ) > 0 ", term])
  end

  def to_s
    name
  end

end
