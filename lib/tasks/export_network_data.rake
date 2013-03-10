# -*-ruby-*-
def get_network(network_type)

  STDERR.puts "Finding networks of #{network_type}"

  output = [ ]
  output_filename = "/tmp/#{network_type}-network.data"

  Person.all.each do |person|
    begin
      STDERR.puts "\tPerson '#{person.id}'"
      person.nodes.each do |node|
        STDERR.puts "\t\tNode '#{node.id}'"
        yield person, node, output
      end
    rescue Exception => e
      STDERR.puts "Problem... next!"
      STDERR.puts "\tException class: #{e.class}"
      STDERR.puts "\tException message: #{e.message}"
    end
  end
  
  File.open(output_filename, 'w') {  |f| f.puts output.join("\n") }
end

namespace :network do

  desc 'Generate data for authoring collaboration'
  task :authoring => :environment do

    get_network 'authoring' do |person, node, output|
      node.people.each do |other|
        next if other == person
        STDERR.puts "\t\t\tCollaborator '#{other.id}'"
        output << ["P#{person.id}", "N#{node.id}", 'authoring'].join("\t")
      end
    end
  end

  desc 'Generate data for attachment collaboration'
  task :attaching => :environment do

    get_network 'attaching' do |person, node, output|
      node.attachments.each do |attachment|
        next if attachment.person == person
        STDERR.puts "\t\t\tCollaborator '#{other.id}'"
        output << ["P#{person.id}", "N#{node.id}", 'attaching'].join("\t")
      end
    end
  end

  desc 'Generate data for recommendation collaboration'
  task :recommending => :environment do

    get_network 'recommending' do |person, node, output|
      node.recommendations.each do |recommendation|
        next if recommendation.person == person
        STDERR.puts "\t\t\tCollaborator '#{recommendation.person.id}'"
        output << ["P#{person.id}", "N#{node.id}", 'recommending'].join("\t")
      end
    end
  end
end
