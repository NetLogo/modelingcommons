class Person < ActiveRecord::Base
  has_many :node_versions
  has_many :nodes, :through => :node_versions

  has_many :postings
  has_many :news_items
  has_many :logged_actions
  has_many :tags
  has_many :tagged_nodes
  has_many :recommendations
  has_many :email_recommendations

  has_many :memberships
  has_many :groups, :through => :memberships, :order => :name

  attr_accessor :password_confirmation

  validates_presence_of :first_name, :last_name, :email_address, :password
  validates_uniqueness_of :email_address
  validates_confirmation_of :password

  def models
    self.nodes.select {|n| n.node_type_id == 1}.uniq
  end

  def fullname
    "#{self.first_name} #{self.last_name}"
  end

  def administrated_groups
    self.groups.select {|g| g.is_administrator?(self) }
  end

end
