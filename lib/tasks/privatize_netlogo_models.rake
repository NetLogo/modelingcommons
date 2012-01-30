# -*-ruby-*-
require 'find'

def get_model_locations
  @model_locations = ENV['MODEL_LOCATIONS']

  if @model_locations.blank?
    puts "Did not find any value for model locations in the MODEL_LOCATIONS environment variable! Exiting."
    exit
  end
  puts "Model locations = '#{@model_locations}'"
end

def get_group
  group_name = ENV['GROUP_NAME']

  if group_name.blank?
    puts "Did not find any value for group name in the GROUP_NAME environment variable! Exiting."
    exit
  end

  Group.find_or_create_by_name(group_name)
end

def get_tag
  tag_name = ENV['TAG_NAME']

  if tag_name.blank?
    puts "Did not find any value for tag name in the TAG_NAME environment variable! Exiting."
    exit
  end

  Tag.find_or_create_by_name(tag_name)
end

def get_uri_user
  @uri_user = Person.find_by_email_address("uri@northwestern.edu")
  if @uri_user.nil?
    puts "Did not find any user for Uri Wilensky! Exiting."
    exit
  end
end

def setup
  get_model_locations
  @group = get_group
  @tag = get_tag
  get_uri_user

  @user_permission = PermissionSetting.find_by_short_form('u')
  @group_permission = PermissionSetting.find_by_short_form('g')
  @everyone_permission = PermissionSetting.find_by_short_form('a')
end

def skip_directory?(directory_name)
  true if File.basename(directory_name) =~ /^\.{1,2}$/
end

namespace :netlogo do

  desc 'Makes models private to the named group'
  task :privatize_models => :environment do

    setup

    Find.find(@model_locations) do |path|

      puts "\n"
      puts "\tpath = '#{path}'"
      Find.prune and next if skip_directory?(path)

      filename = File.basename(path).slice(/^[^.]+/)
      puts "\t\tfilename = '#{filename}'"

      suffix = path.slice(/\.\w+$/)

      # Get matches, and handle accordingly
      matching_nodes = Node.all(:conditions => { :name => filename} ).select { |n| n.people.member?(@uri_user) }

      if suffix == '.nlogo'

        if matching_nodes.empty?
          puts "\t\tDid not find any nodes named '#{filename}'"

        elsif matching_nodes.length == 1
          matching_node = matching_nodes.first

          puts "\t\tFound a matching node, with a group of '#{matching_node.group}', visibility '#{matching_node.visibility}' and changeability '#{matching_node.changeability}'"

          matching_node.update_attributes!(:group => @group,
                                           :visibility => @group_permission,
                                           :changeability => @group_permission)

          puts "\t\t\tSet to group '#{@group}', visibility '#{@group_permission}', changeability '#{@group_permission}'"

          if matching_node.tags.include?(@tag)
            puts "\t\tNot adding the '#{@tag}' tag, because it is already there"
          else
            tn = TaggedNode.create(:node => matching_node, :tag => @tag.id, :person => @uri_user, :comment => 'Automatic import')
          end

        else
          # Too many to choose from -- aborting!
          puts "\t\tFound more than one. Ack!"
        end

      else
        puts "\tIgnoring this file."
      end # if
    end # find

    puts "Done."
  end
end
