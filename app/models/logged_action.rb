class LoggedAction < ActiveRecord::Base
  belongs_to :person
  belongs_to :node
end
