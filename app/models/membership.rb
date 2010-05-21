# Each person may be a member of any number of groups.  A group member
# may optionally be an administrator.

class Membership < ActiveRecord::Base
  validates_presence_of :person, :group

  belongs_to :person
  belongs_to :group

  after_destroy :remove_group_if_empty

  def remove_group_if_empty
    group.destroy if group.members.empty?
  end

end
