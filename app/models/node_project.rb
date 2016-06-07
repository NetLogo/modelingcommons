# Join table between nodes and projects.  (Needed because a project may contain multiple
# nodes, and a node may be in multiple projects)

class NodeProject < ActiveRecord::Base

  attr_accessible :node_id, :project_id

  belongs_to :node
  belongs_to :project

  validates :node_id, :uniqueness => { :scope => :project_id }
end
