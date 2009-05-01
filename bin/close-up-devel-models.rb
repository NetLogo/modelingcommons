#!/usr/local/bin/ruby

require 'rubygems'
require 'active_record'

ignored_directories = [".", "..", ".svn"]

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

  puts "Directory: '#{dirname}'"

  if !FileTest.exists?(dirname)
    puts "\tThe file '#{dirname}' does not exist."
    next
  end

  # Now open the directory
  Dir.foreach(dirname) do |filename|

    next if ignored_directories.member?(filename)

    full_path = dirname + '/' + filename
    puts "\tChecking file '#{full_path}'"

    if FileTest.directory?(full_path)
      ARGV << full_path
      puts "\t\tAdding directory '#{full_path}'"
      next
    end

    if filename =~ /.nlogo$/
      puts "\t\tNetLogo file: '#{filename}'"

      node = Node.find_by_name(filename.gsub('.nlogo', ''))
      if node.nil?
        puts "\t\t\tNot found in the Modeling Commons"
      else
        puts "\t\t\tFound; node ID '#{node.id}' with visibility '#{node.visibility.short_form}' and changeability '#{node.changeability.short_form}', with a group of '#{node.group.name}'."

        # In general:
        # Set group = CCL
        # Set visibility = ANYONE
        # Set changeability = GROUP

        # For "under development" and "little things", permissions should be
        # Set group = CCL
        # Set visibility = GROUP
        # Set changeability = GROUP

        node.group = ccl_group
        node.visibility_id = ANYONE
        node.changeability_id = GROUP

        if node.save
          puts "\t\t\tUpdated group and permissions"
        else
          puts "\t\t\tERROR updating group and permissions"
        end
      end
    else
      puts "\t\tIgnoring non-NetLogo file '#{filename}'"
    end
  end
end

