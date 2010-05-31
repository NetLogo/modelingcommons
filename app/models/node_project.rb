# Join table between nodes and projects.  (Needed because a project may contain multiple
# nodes, and a node may be in multiple projects)

class NodeProject < ActiveRecord::Base

  belongs_to :node
  belongs_to :project

  validates_uniqueness_of :node_id, :scope => :project_id
end
