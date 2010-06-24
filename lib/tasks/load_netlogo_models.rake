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

    # Go through each model file we find
    Find.find(MODEL_LOCATIONS) do |path|

      if FileTest.directory?(path)

        if File.basename(path) == '.' or
            File.basename(path) == '..' or
            File.basename(path) == 'under development' or
            File.basename(path) == 'under development'
          Find.prune
        end

        next
      else
        puts "Now looking at file '#{path}'"

        filename = File.basename(path).slice(/^[^.]+/)
        puts "\tfilename = '#{filename}'"

        suffix = path.slice(/\.\w+$/)
        puts "\tsuffix = '#{suffix}'"

        matching_nodes = Node.all(:conditions => { :name => filename} ).select { |n| n.people.member?(mc_user)}

        if suffix == '.nlogo'

          if matching_nodes.empty?
            # Create a new node, if necessary
            puts "\t\tNo matching node found.  We will need to create a new one."

          elsif matching_nodes.length == 1
            # Add a new version to an existing node
            puts "\t\tFound a matching node.  Creating a new node_version."

          else
            # Too many to choose from -- aborting!
            puts "\t\tFound more than one.  Ack!"
          end

        elsif suffix == '.png'

          if matching_nodes.empty?
            # Create a new node, if necessary
            puts "\t\tNo matching node found.  What the heck?"

          elsif matching_nodes.length == 1
            # Add a new version to an existing node
            puts "\t\tFound a matching node.  Creating a new attachment, of type preview."

          else
            # Too many to choose from -- aborting!
            puts "\t\tFound more than one.  Ack!"
          end

        else
          puts "\t\tI have no idea what to do with a suffix of '#{suffix}'.  Ignoring."
        end
      end
    end
  end
end
