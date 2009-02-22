class SpamWarning < ActiveRecord::Base
  belongs_to :person
  belongs_to :model
end
