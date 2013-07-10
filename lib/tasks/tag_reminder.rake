# -*-ruby-*-

namespace :nlcommons do

  desc 'Send e-mail reminders to people whose models lack tags'
  task :tag_reminder => :environment do 
    if ENV['DAYS_AGO'].blank?
      STDERR.puts "Error: DAYS_AGO environment variable first was not defined.  Exiting."
      exit
    end

    minimum_creation_age = ENV['DAYS_AGO'].to_i.days.ago
    STDERR.puts "sending e-mail to owners of models created up to #{minimum_creation_age} days ago, which lack tags."

    Person.all.each do |person|
      STDERR.puts "Person ID #{person.id}, #{person.email_address}"
      if !person.send_tag_updates?
        STDERR.puts "\tSkipping, because of personal options"
        next
      end

      untagged_models = person.models.select {|m| m.tags.empty? and m.updated_at > minimum_creation_age}
      if untagged_models.empty?
        STDERR.puts "\tNo untagged models"
      else
        STDERR.puts "\tSending e-mail, for models #{untagged_models.map {|m| m.id}.to_sentence}"
        Notifications.untagged_models_reminder(person, untagged_models).deliver
      end
    end
  end
end
