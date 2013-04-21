class CollaboratorType < ActiveRecord::Base
  attr_accessible :name
  validates :name, :presence => true, :uniqueness => true

  has_many :collaborations

  default_scope :order => 'name ASC'
end
