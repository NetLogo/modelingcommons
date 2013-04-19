# Class that marks a node as potentially spam.  Each user may indicate
# that a model is spam; administrators can then go and remove such
# models from the system.

class SpamWarning < ActiveRecord::Base
  attr_accessible :node_id, :person_id
  
  belongs_to :person
  belongs_to :node

  after_save :notify_administrators

  def notify_administrators
    Notifications.spam_warning(node, person).deliver
  end


end
