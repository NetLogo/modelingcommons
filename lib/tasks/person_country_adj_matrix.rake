# -*-ruby-*-

namespace :nlcommons do

  desc 'Create an adjacency matrix for people/country overlap'
  task :person_country_adj_matrix => :environment do 

    output = [ ]

    sorted_people = Person.all.sort_by {|p| p.id}

    # Header row
    row = [nil]
    sorted_people.each do |person|
      row << person.id
    end
    output << row.join("\t")

    # For each person, indicate whether there is a country overlap or no
    sorted_people.each do |person|
      row = [person.id]
      sorted_people.each do |person2|
        if person.country_name == person2.country_name
          row << [1]
        else
          row << [0]
        end
      end
      output << row.join("\t")
    end

    output.each do |row|
      puts row
    end

  end
end
