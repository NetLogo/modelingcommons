# Each action in the Modeling Commons is logged.  This is the class
# that keeps track of such logs.

class LoggedAction < ActiveRecord::Base
  belongs_to :person
  belongs_to :node
end
