class Group < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name

  has_many :memberships
  has_many :people, :through => :memberships

  has_many :nodes

  def self.to_hash
    groups = Group.find(:all)
    groups.inject({ }) do |hash, group|
      hash[group.name] = group.id
      hash
    end
  end

  def members
    self.memberships.map {|m| m.person}
  end

  def approved_members
    self.memberships.select {|m| m.status == 'approved'}.map {|m| m.person}
  end

  def is_administrator?(person)
    not self.memberships.select {|m| m.person == person and m.is_administrator?}.empty?
  end

  def administrators
    self.memberships.select {|m| m.person if m.is_administrator? }
  end

  def models
    self.nodes
  end

end
