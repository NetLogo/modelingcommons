# Model to keep track of projects (i.e., collections of models)

class Project < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name

  has_many :node_projects
  has_many :nodes, :through => :node_projects, :conditions => ["node_type_id = ? ", Node::MODEL_NODE_TYPE]

end
