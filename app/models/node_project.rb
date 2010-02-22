class NodeProject < ActiveRecord::Base

  belongs_to :node
  belongs_to :project

end
