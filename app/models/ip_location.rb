class IpLocation < ActiveRecord::Base
  
  attr_accessible :ip_address, :location
  
  validates :ip_address, :presence => true

end
