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

def get_mc_user
  @mc_user = Person.find_by_email_address("nlcommons@modelingcommons.org")
  if @mc_user.nil?
    puts "Did not find any user for the Modeling Commons! Exiting."
    exit
  end
end

def setup
  get_model_locations
  get_mc_user

  @ccl_group = Group.find_or_create_by_name('CCL')
  @ccl_tag = Tag.find_or_create_by_name('ccl', :person_id => @mc_user.id)
  @community_models_tag = Tag.find_or_create_by_name('community models', :person_id => @mc_user.id)
end

def skip_directory?(directory_name)
  true if File.basename(directory_name) == '.' or 
    File.basename(directory_name) == '..' or 
    File.basename(directory_name) == 'under development'
end

namespace :netlogo do

  desc 'Loads the latest batch of models from the filesystem into the Modeling Commons'
  task :load_models => :environment do

    setup

    Find.find(@model_locations) do |path|

      puts "\n"
      puts "\tpath = '#{path}'"
      Find.prune and next if skip_directory?(path)

      filename = File.basename(path).slice(/^[^.]+/)
      puts "\t\tfilename = '#{filename}'"

      suffix = path.slice(/\.\w+$/)
      puts "\t\tsuffix = '#{suffix}'\n"

      # Get matches, and handle accordingly
      matching_nodes = Node.all(:conditions => { :name => filename} ).select { |n| n.people.member?(@mc_user)}

      if suffix == '.nlogo'

        if matching_nodes.empty?

          # Create a new node, if necessary
          puts "\t\tNo matching node found. We will need to create a new one."

          node = Node.new(:parent_id => nil, :name => filename,
                          :group => ccl_group, :changeability => PermissionSetting.group)

          if !node.save
            puts "\t\t*** Error trying to save a new node."
            puts "\t\t\t#{node.errors.inspect}"
          end

          # Add ccl tag to this model
          puts "\tAdding CCL tag, ID '#{ccl_tag.id}' for node_id '#{node.id}', person_id '#{mc_user.id}'"
          tn = TaggedNode.new(:node_id => node.id, :tag_id => ccl_tag.id, :person_id => mc_user.id, :comment => '')
          
          if !tn.save
            puts "\t\t*** Error trying to save a new tagged node."
            puts "\t\t\t#{tn.errors.inspect}"
          end

          # Add community models tag to this model
          if path =~ /community model/
            puts "\tAdding community models tag, ID '#{community_models_tag.id}'"
            tn = TaggedNode.new(:node_id => node.id, :tag_id => community_models_tag.id, :person_id => mc_user.id, :comment => '')
            if !tn.save
              puts "\t\t*** Error trying to save a new tagged node."
              puts "\t\t\t#{tn.errors.inspect}"
            end
          end

          file_contents = File.open(path).read

          new_version = NodeVersion.new(:node_id => node.id,
                                        :person_id => @mc_user.id,
                                        :contents => file_contents,
                                        :description => 'Updated from NetLogo 5.0')

          if !new_version.save
            puts "\t\t*** Error trying to save a new version of the new node '#{node.name}', ID '#{node.id}': '#{e.inspect}'"
            puts "\t\t\t#{node.inspect}"
          end


        elsif matching_nodes.length == 1
          matching_node = matching_nodes.first

          # Add a new version to an existing node

          puts "\t\tAbout to check node.contents"
          if matching_node and matching_node.contents == file_contents
            puts "\t\tNot adding a new version -- current one is identical"
            next
          else
            puts "\t\tFound a matching node. Creating a new node_version for this node."
          end
          
          model_contents = File.open(path).read

          if model_contents.blank?
            puts "\t\t\tNo content the model in file '#{path}'!"
            next
          else
            puts "\t\t\tModel is '#{model_contents.length}' characters long."
          end

          new_version =
            nv = NodeVersion.new(:node_id => matching_node.id,
                                 :person_id => @mc_user.id,
                                 :contents => model_contents,
                                 :description => 'Updated to NetLogo 5.0RC7')
          if nv.save
            puts "\t\t\tSuccessfully saved a new node_version"
          else
            puts "\t\t*** Error trying to create a new version of existing node '#{matching_node.name}', ID '#{matching_node.id}': '#{e.inspect}'"
            next

          end

        else
          # Too many to choose from -- aborting!
          puts "\t\tFound more than one. Ack!"
        end

      elsif suffix == '.png'
        puts "\tIgnoring .png preview -- we will get back to it later."
      else
        puts "\tIgnoring this file, with an unknown file type of '#{suffix}'."
      end # if
    end # find


    # Now we will look for previews. We could have done it in the previous find loop, but
    # then we ran a big risk of finding the preview before the node.


    # Add any nodes we find
    Find.find(@model_locations) do |path|
      puts "Now looking at file '#{path}'"

      # Skip directories
      if FileTest.directory?(path)
        if File.basename(path) == '.' or File.basename(path) == '..' or File.basename(path) == 'under development'
          Find.prune
        end
        puts "\tSkipping directory '#{path}'"
        next

        # Handle files
      else
        filename = File.basename(path).slice(/^[^.]+/)
        puts "\tfilename = '#{filename}'"

        suffix = path.slice(/\.\w+$/)
        puts "\tsuffix = '#{suffix}'"

        # Get matches, and handle accordingly
        matching_nodes = Node.all(:conditions => { :name => filename} ).select { |n| n.people.member?(@mc_user)}

        if suffix == '.png'

          if matching_nodes.empty?
            puts "\t\tNo matching node found. What the heck?"

          elsif matching_nodes.length == 1
            matching_node = matching_nodes.first
            # Add a new version to an existing node
            puts "\t\tFound a matching node. Creating a new attachment, of type preview."

            file_contents = File.open(path).read
            if node.preview.contents == file_contents
              puts "\t\tNot adding a new version -- current one is identical"
              next
            end

            begin
              new_version =
                attachment = NodeAttachment.create!(:node_id => matching_node.id,
                                                    :person_id => @mc_user.id,
                                                    :description => "Preview for '#{filename}'",
                                                    :filename => filename + '.png',
                                                    :type => 'preview',
                                                    :contents => file_contents)
            rescue => e
              puts "\t\t*** Error trying to create a attachment to node '#{matching_node.name}', ID '#{matching_node.id}'"
              next
            end

          elsif suffix == '.nlogo'
            puts "\tIgnoring .nlogo file -- we dealt with these earlier."
          else
            puts "\tIgnoring this file, with an unknown file type of '#{suffix}'."
          end # if empty
        end # if suffix
      end # if Filetest
    end # find

    puts "Done."
  end
end
