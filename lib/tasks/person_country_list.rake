# -*-ruby-*-

namespace :nlcommons do

  desc 'Create an adjacency matrix for people/country overlap'
  task :person_country_list => :environment do 

    countries = { }
    output = [ ]

    sorted_people = Person.all.sort_by {|p| p.id}
    sorted_countries = Person.select("country_name").all.map {|p| p.country_name.to_s}.uniq.sort

    File.open('country_names_codes.csv', 'w') do |f|
      sorted_countries.each_with_index do |country_name, index|
        f.puts "#{country_name}\t#{index}"
        countries[country_name] = index
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
      output << [person.id, countries[person.country_name]].join("\t")
    end

    output.each do |row|
      puts row
    end
  end
end
