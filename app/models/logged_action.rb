# Each action in the Modeling Commons is logged.  This is the class
# that keeps track of such logs.

class LoggedAction < ActiveRecord::Base
  attr_accessible :person_id, :controller, :action, :logged_at, :message, :ip_address, :browser_info, :url, :params, :session, :cookies, :flash, :referrer, :node_id, :is_searchbot

  belongs_to :person
  belongs_to :node

end
