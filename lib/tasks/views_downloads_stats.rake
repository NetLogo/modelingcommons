# -*-ruby-*-

namespace :nlcommons do

  desc 'Tell people, via e-mail, how many times their models have been seen and downloaded'
  task :views_downloads_stats => :environment do 

    STDERR.puts "Sending e-mail to owners of models, with download and view stats"

    Person.all.each do |person|
      STDERR.puts "Person ID #{person.id}, #{person.email_address}"

      if person.models.empty?
        STDERR.puts "\tThis person has no models"
      elsif !person.send_model_updates?
        STDERR.puts "\tSkipping, because of personal options"
      else
        STDERR.puts "\tSending e-mail, for models #{person.models.map {|m| m.id}.to_sentence}"
        Notifications.views_downloads_update(person).deliver
      end
    end
  end
end
