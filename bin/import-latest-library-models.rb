#!/usr/bin/ruby

require 'rubygems'
require 'active_record'
require 'find'

ignored_directories = [".", "..", ".svn", 'benchmarks',
                       'HubNet Computer Activities', 'user community models',
                       'under development']

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
  belongs_to :person
  has_one :node
end

class Person < ActiveRecord::Base
  has_many :node_versions
  has_many :nodes, :through => :node_versions
end

# Talk to the database
ActiveRecord::Base.establish_connection(:adapter  => 'postgresql',
                                        :database => 'nlcommons_production',
                                        :username => 'nlcommons',
                                        :password => 'nlcommons',
                                        :host     => 'localhost')

modeling_commons_user = Person.find_by_first_name_and_last_name('Modeling', 'Commons')

if modeling_commons_user.nil?
  puts "No such user 'Modeling' 'Commons' -- try again"
  exit
end

ARGV.each do |dirname|

  puts "Invoking find on '#{dirname}'"

  Find.find(dirname) do |filename|

    puts "Now looking at '#{filename}'"

    filename_no_path = File.basename(filename)
    if ignored_directories.member?(filename_no_path)
      puts "\tPruning '#{filename}'"
      Find.prune       # Don't look any further into this directory.
      next
    end

    next if FileTest.directory?(filename)

    if filename_no_path =~ /.nlogo$/
      puts "\t\tNetLogo file: '#{filename_no_path}'"

      model_name = filename_no_path.gsub('.nlogo', '')

      node = Node.find_by_name(model_name)

      file_contents = ''
      File.open(filename) do |f|
        file_contents = f.readlines.join("\n")
      end

      Node.transaction do

        puts "\n"

        if node.nil?
          puts "\t\t\tNot found in the Modeling Commons"
          puts "\t\t\t\tSo we will need to add it!"

          node = Node.new(:node_type_id => 1,
                          :name => model_name)

          if node.save
            puts "\tSuccessfully saved a new node for '#{model_name}', node ID '#{node.id}'"
          else
            puts "\tError saving '#{model_name}'"
          end

          # Add a node

          # Add a node version
        end


        puts "\t\t\t\tNow adding a new version to node '#{model_name}', ID '#{node.id}'"

        nv = NodeVersion.new(:node_id => node.id,
                             :person => modeling_commons_user,
                             :description => "Model from NetLogo distribution",
                             :file_contents => file_contents)

        if nv.save
          puts "\tSuccessfully saved a new version of '#{filename_no_path}', node version ID '#{nv.id}'"
        else
          puts "\tError saving '#{filename_no_path}'!"
        end

      end

    else
      puts "\t\tIgnoring non-NetLogo file '#{filename}'"
    end
  end
end
