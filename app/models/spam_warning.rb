# Class that marks a node as potentially spam.  Each user may indicate
# that a model is spam; administrators can then go and remove such
# models from the system.

class SpamWarning < ActiveRecord::Base
  belongs_to :person
  belongs_to :node

  after_save :send_email

  def notify_administrators
    Notifications.report_spam_to_administrators(node, person) 
  end


end
