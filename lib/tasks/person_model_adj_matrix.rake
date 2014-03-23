# -*-ruby-*-

namespace :nlcommons do

  desc 'Create an adjacency matrix for people/country overlap'
  task :person_model_adj_matrix => :environment do 

    non_ccl_output = [ ]
    output = [ ]

    sorted_people = Person.all.sort_by {|p| p.id}
    sorted_nodes = Node.all.sort_by {|n| n.id}

    # For each person, indicate whether they are an author or not

    sorted_people.each do |person|
      row = []
      non_ccl_row = []
      sorted_nodes.each do |node|
        # STDERR.puts "Checking person '#{person.fullname}' and model '#{node.name}'"
        if node.author?(person)
          row << [1]
          non_ccl_row << [1] unless node.group_id == 2
        else
          row << [0]
          non_ccl_row << [0] unless node.group_id == 2
        end
      end
      output << row.join("\t")
      non_ccl_output << non_ccl_row.join("\t") 
    end

    output.each do |row|
      puts row
    end

    File.open('non-ccl-nodes.xls', 'w') do |f|
      non_ccl_output.each do |row|
        f.puts row
      end
    end
  end
end
