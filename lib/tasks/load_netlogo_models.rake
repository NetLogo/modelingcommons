require 'find'

namespace :netlogo do

  desc 'Loads the latest batch of models from the filesystem into the Modeling Commons'
  task :load_models => :environment do

    MODEL_LOCATIONS = ENV['MODEL_LOCATIONS']

    if MODEL_LOCATIONS.blank?
      puts "Did not find any value for model locations! Exiting."
      exit
    end
    puts "Model locations = '#{MODEL_LOCATIONS}'"

    # Get the Modeling Commons user
    mc_user = Person.find_by_email_address("nlcommons@modelingcommons.org")
    if mc_user.nil?
      puts "Did not find any user for the Modeling Commons!  Exiting."
      exit
    end

    # Get the CCL group
    ccl_group = Group.find_or_create_by_name('CCL')

    # Get appropriate tags
    ccl_tag = Tag.find_or_create_by_name('CCL', :person_id => mc_user.id)
    community_models_tag = Tag.find_or_create_by_name('community models', :person_id => mc_user.id)

    # Add any nodes we find
    Find.find(MODEL_LOCATIONS) do |path|
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
        matching_nodes = Node.all(:conditions => { :name => filename} ).select { |n| n.people.member?(mc_user)}

        if suffix == '.nlogo'

          if matching_nodes.empty?

            # Create a new node, if necessary
            puts "\t\tNo matching node found.  We will need to create a new one."

            begin
              node = Node.create!(:parent_id => nil, :name => filename,
                                  :group => ccl_group, :changeability => PermissionSetting.group)

              # Add ccl tag to this model
              puts "\tAdding CCL tag, ID '#{ccl_tag}'"
              TaggedNode.create!(:node_id => node.id, :tag_id => ccl_tag.id, :person_id => mc_user.id, :comment => '')

              # Add community models tag to this model
              if path =~ /community model/
              puts "\tAdding community models tag, ID '#{community_models_tag.id}'"
                TaggedNode.create!(:node_id => node.id, :tag_id => community_models_tag.id, :person_id => mc_user.id, :comment => '')
              end

              new_version = NodeVersion.create!(:node_id => node.id,
                                                :person_id => mc_user.id,
                                                :contents => File.open(path).read,
                                                :description => 'Updated from NetLogo 4.1')
            rescue => e
              puts "\t\t*** Error trying to save a new version of the new node '#{node.name}', ID '#{node.id}': '#{e.inspect}'"
              puts "\t\t\t#{node.inspect}"
            end

          elsif matching_nodes.length == 1
            matching_node = matching_nodes.first

            # Add a new version to an existing node
            puts "\t\tFound a matching node.  Creating a new node_version for this node."

            begin
              new_version =
                NodeVersion.create!(:node_id => matching_node.id,
                                    :person_id => mc_user.id,
                                    :contents => File.open(path).read,
                                    :description => 'Updated from NetLogo 4.1')
            rescue => e
              puts "\t\t*** Error trying to create a new version of existing node '#{node.name}', ID '#{node.id}': '#{e.inspect}'"
              next
            end

          else
            # Too many to choose from -- aborting!
            puts "\t\tFound more than one.  Ack!"
          end

        elsif suffix == '.png'
          puts "\tIgnoring .png preview -- we will get back to it later."
        else
          puts "\tIgnoring this file, with an unknown file type of '#{suffix}'."
        end # if
      end # if Filetest
    end # find


    # Now we will look for previews.  We could have done it in the previous find loop, but
    # then we ran a big risk of finding the preview before the node.


    # Add any nodes we find
    Find.find(MODEL_LOCATIONS) do |path|
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
        matching_nodes = Node.all(:conditions => { :name => filename} ).select { |n| n.people.member?(mc_user)}

        if suffix == '.png'

          if matching_nodes.empty?
            # Create a new node, if necessary
            puts "\t\tNo matching node found.  What the heck?"

          elsif matching_nodes.length == 1
            # Add a new version to an existing node
            puts "\t\tFound a matching node.  Creating a new attachment, of type preview."

            begin
              new_version =
                attachment = NodeAttachment.create!(:node_id => matching_nodes.first.id,
                                                    :person_id => mc_user.id,
                                                    :description => "Preview for '#{filename}'",
                                                    :filename => filename + '.png',
                                                    :type => 'preview',
                                                    :contents => File.open(path).read)
            rescue => e
              puts "\t\t*** Error trying to create a attachment to node '#{node.name}', ID '#{node.id}'"
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
