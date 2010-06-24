# Model that represents a group.  Groups in the Modeling Commons
# describe collections of people for the purposes of sectioning models
# off from being generally viewable.

class Group < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name

  has_many :memberships
  has_many :people, :through => :memberships

  has_many :nodes
  has_many :models, :class_name => 'Node', :include => :tags

  before_destroy :remove_group_from_models

  named_scope :search, lambda { |term| { :conditions => ["lower(name) ilike ? ", term] } }

  def approved_members
    memberships.approved_members
  end

  def administrators
    memberships.administrators
  end

  def members
    people
  end

  def is_administrator?(person)
    administrators.member?(person)
  end

  def remove_group_from_models
    models.each do |model|
      new_settings = { :group => nil }

      new_settings[:visibility_id] = 1 if model.group_visible?
      new_settings[:changeability_id] = 1 if model.group_changeable?

      model.update_attributes(new_settings)
    end
  end

  def self.group_or_nil(group_id)
    first(:conditions => { :id => group_id })
  end


end
