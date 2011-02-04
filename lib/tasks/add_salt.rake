namespace :netlogo do

  desc 'Upgrade everyone in the Modeling Commons to have salt, based on a secret and created_at'
  task :add_salt => :environment do

    Person.transaction do 
      Person.all.each do |person|
        STDERR.puts "Person '#{person.fullname}'"

        salt = Person.generate_salt(person.created_at)
        STDERR.puts "\tSalt = '#{salt}'"

        encrypted_password = Person.encrypted_password(salt, person.password)
        STDERR.puts "\tEncrypted password = '#{encrypted_password}'"

        person.update_attributes!(:salt => salt,
                                  :password => encrypted_password)
      end
    end

  end
end
