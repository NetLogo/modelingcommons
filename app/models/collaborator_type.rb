class CollaboratorType < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name

  has_many :collaborations

  default_scope :order => 'name ASC'
end
