#!/usr/local/bin/ruby

require 'rubygems'
require 'active_record'

# Define node versions
require '../app/models/permission_setting.rb'

# Define nodes
class Node < ActiveRecord::Base
  has_many :node_versions
  belongs_to :visibility, :class_name => "PermissionSetting", :foreign_key => :visibility_id
  belongs_to :changeability, :class_name => "PermissionSetting", :foreign_key => :changeability_id
  belongs_to :group
end

class NodeVersion < ActiveRecord::Base
  has_one :node
end

class Group < ActiveRecord::Base
  has_many :nodes
end

ActiveRecord::Base.establish_connection(:adapter  => 'postgresql',
                                        :database => 'nlcommons_development',
                                        :username => 'reuven',
                                        :password => 'reuven',
                                        :host     => 'localhost')

autumn = Node.find_by_name("Autumn")
puts autumn.inspect
exit

nodes = Node.find(:all,
                  :conditions => "node_type_id = 1",
                  :include => [:visibility, :changeability, :node_versions])

nodes.each_with_index do |node, index|
  break if index > 10

  puts "#{node.name}: Readability '#{node.visibility.short_form}', Changeability '#{node.changeability.short_form}', Group '#{node.group.name}'"
end
