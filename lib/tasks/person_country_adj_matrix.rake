# -*-ruby-*-

namespace :nlcommons do

  desc 'Create a table of people/country overlap'
  task :person_country_adj_matrix => :environment do 

    output = [ ]

    sna_people = Person.sna_people
    sna_countries = sna_people.map {|p| p.country_name.to_s}.uniq.sort

    File.open('country_names_codes.csv', 'w') do |f|
      sna_countries.each_with_index do |country_name, index|
        f.puts "#{country_name}\t#{index}"
      end
    end

    dummy_country_id = 1000

    sna_people.each do |person|
      row = []
      sna_countries.each do |country_name|

        if country_name.nil? or country_name == ''
          country_name = dummy_country_id
          dummy_country_id += 1
        end

        row << ((person.country_name == country_name) ? 1 : 0)
      end
      output << row.join("\t")
    end

    output.each do |row|
      puts row
    end

  end
end
