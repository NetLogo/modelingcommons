# -*-ruby-*-

namespace :nlcommons do

  desc 'Send e-mail reminders to people whose models lack collaborators'
  task :collaboration_reminder => :environment do 
    if ENV['DAYS_AGO'].blank?
      STDERR.puts "Error: DAYS_AGO environment variable first was not defined.  Exiting."
      exit
    end

    minimum_creation_age = ENV['DAYS_AGO'].to_i.days.ago
    STDERR.puts "sending e-mail to owners of models created up to #{minimum_creation_age} days ago, which lack collaborators."

    Person.all.each do |person|
      STDERR.puts "Person ID #{person.id}, #{person.email_address}"
      if !person.send_model_updates?
        STDERR.puts "\tSkipping, because of personal options"
        next
      end

      solo_models = person.models.select {|m| (m.all_collaborations.size == 1) and m.created_at > minimum_creation_age}
      if solo_models.empty?
        STDERR.puts "\tNo solo models"
      else
        STDERR.puts "\tSending e-mail, for models #{solo_models.map {|m| m.id}.to_sentence}"
        Notifications.solo_models_reminder(person, solo_models).deliver
      end
    end
  end
end
