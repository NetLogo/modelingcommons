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
        row << (node.author?(person)) ? 1 : 0
      end

      output << row.join("\t") 
    end

    output.each do |row|
      puts row
    end
  end
end
