#!/usr/local/bin/ruby

require 'rubygems'
require 'active_record'
require 'find'

ignored_directories = [".", "..", ".svn", 'benchmarks', 'HubNet Computer Activities']

# Make sure that we got an argument!
if ARGV.empty?
  puts "#{$0}: You must enter a directory name."
  exit
end

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

# Talk to the database
ActiveRecord::Base.establish_connection(:adapter  => 'postgresql',
                                        :database => 'nlcommons_development',
                                        :username => 'reuven',
                                        :password => 'reuven',
                                        :host     => 'localhost')


ARGV.each do |dirname|

  puts "Invoking find on '#{dirname}'"

  Find.find(dirname) do |filename|


    puts "Now looking at '#{filename}'"

    basename = File.basename(filename)
    if ignored_directories.member?(basename)
      puts "\tPruning '#{filename}'"
      Find.prune       # Don't look any further into this directory.
      next
    end

    next if FileTest.directory?(filename)

    if filename =~ /.nlogo$/
      puts "\t\tNetLogo file: '#{basename}'"

      node = Node.find_by_name(basename.gsub('.nlogo', ''))
      if node.nil?
        puts "\t\t\tNot found in the Modeling Commons"
      else
        node_group_name = node.group ? node.group.name : "No group"
        puts "\t\t\tFound; node ID '#{node.id}' with visibility '#{node.visibility.short_form}' and changeability '#{node.changeability.short_form}', with a group of '#{node.group.name}'."
        puts "\t\t\t\tDirname = '#{filename}'"

        if filename =~ /little things/i
          puts "\t\t\t\tIn 'little things' -- making it only visible to CCLers"

          node.group = Group.find_by_name("CCL")
          node.visibility_id = PermissionSetting::GROUP
          node.changeability_id = PermissionSetting::GROUP
        elsif
          filename =~ /under development/i
          puts "\t\t\t\tIn 'under development' -- making it only visible to CCLers"

          node.group = Group.find_by_name("CCL")
          node.visibility_id = PermissionSetting::GROUP
          node.changeability_id = PermissionSetting::GROUP
        else
          puts "\t\t\t\tMaking it writable only by CCLers"
          node.group = Group.find_by_name("CCL")
          node.visibility_id = PermissionSetting::ANYONE
          node.changeability_id = PermissionSetting::GROUP
        end

        if node.save
          puts "\t\t\tSuccessfully set group and permissions"
        else
          puts "\t\t\tERROR updating group and permissions"
          exit
        end
      end
    else
      puts "\t\tIgnoring non-NetLogo file '#{filename}'"
    end
  end
end
