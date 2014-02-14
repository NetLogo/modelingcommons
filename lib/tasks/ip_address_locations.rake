# -*-ruby-*-

require 'geolocater'
require 'geocoder'

Geocoder.configure(:timeout => 600)

def geocoder_decode(ip_address)
  Geocoder.search(ip_address).location rescue nil
end

def geolocater_decode(ip_address)
  Geolocater.geolocate_ip(ip_address) rescue nil
end

namespace :nlcommons do

  desc 'Get Geolocation information about IP addresses in the database'
  task :get_ip_locations => :environment do 

    LoggedAction.select(:ip_address)
      .where("ip_address NOT IN (SELECT ip_address FROM ip_locations)")
      .limit(10000)
      .map {|la| la.ip_address}
      .each do |ip_address|

      STDERR.puts "Looking for: '#{ip_address}'"
      if IpLocation.exists?(ip_address: ip_address)
        STDERR.puts "\tAlready in database; skipping"
        next
      end
      
      location = geocoder_decode(ip_address) || geolocater_decode(ip_address)
      IpLocation.create!(ip_address: ip_address,  location: location)
      STDERR.puts "\tAdded location '#{location}' for address '#{ip_address}'"

    end
  end
end
