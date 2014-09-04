# -*-ruby-*-

namespace :nlcommons do

  desc 'Create an adjacency matrix for people/country overlap'
  task :person_country_list => :environment do 

    countries = { }
    output = [ ]

    sorted_people = Person.sna_people
    sorted_countries = Person.select("country_name").all.map {|p| p.country_name.to_s}.uniq.sort

    STDERR.puts "Creating country_names_codes CSV file"
    File.open(Rails.root + 'bin/sna/' + 'country_names_codes.csv', 'w') do |f|
      sorted_countries.each_with_index do |country_name, index|
        f.puts "#{country_name}\t#{index}"
        countries[country_name] = index
      end
    end

    # Give people without a country a dummy country ID
    dummy_country_index = 1000

    sorted_people.each do |person|
      country_id = countries[person.country_name]
      if country_id.nil?
        country_id = dummy_country_index
        dummy_country_index += 1
      end

      output << [person.id, country_id].join("\t")
    end

    output.each do |row|
      puts row
    end
  end
end
