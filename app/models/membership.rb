class Membership < ActiveRecord::Base
  validates_presence_of :person, :group

  belongs_to :person
  belongs_to :group

end
