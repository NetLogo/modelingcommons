class NodeType < ActiveRecord::Base
  has_many :nodes

  validates_presence_of :name, :description
  validates_uniqueness_of :name
end
