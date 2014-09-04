# -*-ruby-*-

namespace :nlcommons do

  desc 'Create an adjacency matrix for people/model overlap'
  task :person_model_adj_matrix => :environment do 

    output = [ ]

    sna_people = Person.sna_people
    sna_nodes = Node.sna_nodes

    sna_people.each do |person|
      row = []

      sna_nodes.each do |node|
        row << (node.author?(person) ? '1' : '0')
      end

      output << row.join("\t") 
    end

    output.each do |row|
      puts row
    end

    # Generate a "dummy Uri" file, as well
    uri = Person.find_by_email_address('uri@northwestern.edu')
    uri_attribute_filename = 'uri-attribute.txt'
    File.open(Rails.root + 'bin/sna/' + uri_attribute_filename, 'w') do |f|
      sna_people.each do |person|
        if person == uri
          f.puts '1'
        else
          f.puts '0'
        end
      end

      sna_nodes.each do |node|
        f.puts '0'
      end
    end
  end
end
