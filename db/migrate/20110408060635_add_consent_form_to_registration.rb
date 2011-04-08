class AddConsentFormToRegistration < ActiveRecord::Migration
  def self.up
    Person.all(:conditions => "salt is null").each do |person|
      person.update_attributes!(:salt => Person.generate_salt(Time.now))
      sleep 1
    end

    add_column :people, :registration_consent, :boolean, :default => false
    add_index :people, :registration_consent
  end

  def self.down
    remove_column :people, :registration_consent
  end
end
