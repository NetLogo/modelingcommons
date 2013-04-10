# Join table between nodes and projects.  (Needed because a project may contain multiple
# nodes, and a node may be in multiple projects)

class NodeProject < ActiveRecord::Base

  belongs_to :node
  belongs_to :project

  validates :node_id, :uniqueness => true, :scope => :project_id
end
