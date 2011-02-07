class AddSaltToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :salt, :string

    Person.transaction do 
      Person.all.each do |person|
        STDERR.puts "Now updating person '#{person.fullname}'"
        salt = Person.generate_salt(person.created_at)
        person.update_attributes!(:salt => salt, :password => person.password)
        STDERR.puts "\tDone."
      end
    end

  end

  def self.down
    remove_column :people, :salt
  end
end
