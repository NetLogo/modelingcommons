# Model that represents a group.  Groups in the Modeling Commons
# describe collections of people for the purposes of sectioning models
# off from being generally viewable.

class Group < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name

  has_many :memberships
  has_many :people, :through => :memberships

  has_many :nodes
  has_many :models, :class_name => 'Node', :include => [:tags, :node_versions]

  def members
    self.memberships.map {|membership| membership.person}
  end

  def approved_members
    self.memberships.select {|membership| membership.status == 'approved'}.map {|membership| membership.person}
  end

  def is_administrator?(person)
    not self.memberships.select {|membership| membership.person == person and membership.is_administrator?}.empty?
  end

  def administrators
    self.memberships.select {|membership| m.person if membership.is_administrator? }
  end

end
