class Tag < ActiveRecord::Base
  belongs_to :person

  has_many :tagged_nodes
  has_many :nodes, :through => :tagged_nodes

  validates_presence_of :name, :person_id
  validates_uniqueness_of :name, :case_sensitive => false

  def people
    return self.nodes.map {|model| model.person}.uniq
  end

end
