# -*-ruby-*-

namespace :nlcommons do

  desc 'Create an adjacency matrix for people/country overlap'
  task :person_country_adj_matrix => :environment do 

    output = [ ]

    sorted_people = Person.all.sort_by {|p| p.id}
    sorted_countries = Person.select("country_name").all.map {|p| p.country_name.to_s}.uniq.sort

    File.open('country_names_codes.csv', 'w') do |f|
      sorted_countries.each_with_index do |country_name, index|
        f.puts "#{country_name}\t#{index}"
      end
    end

    # # Header row
    # row = [nil]
    # sorted_people.each do |person|
    #   row << person.id
    # end
    # output << row.join("\t")

    # For each person, indicate whether there is a country overlap or no

    sorted_people.each do |person|
      row = []
      sorted_countries.each do |country_name|
        if person.country_name == country_name
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
