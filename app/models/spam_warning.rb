# Class that marks a node as potentially spam.  Each user may indicate
# that a model is spam; administrators can then go and remove such
# models from the system.

class SpamWarning < ActiveRecord::Base
  belongs_to :person
  belongs_to :node

  after_save :notify_administrators

  def notify_administrators
    Notifications.deliver_spam_warning(node, person) 
  end


end
