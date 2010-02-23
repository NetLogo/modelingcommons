class NodeProject < ActiveRecord::Base

  belongs_to :node
  belongs_to :project

  validates_uniqueness_of :node_id, :scope => :project_id
end
