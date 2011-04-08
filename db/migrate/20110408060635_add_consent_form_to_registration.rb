class AddConsentFormToRegistration < ActiveRecord::Migration
  def self.up
    add_column :people, :registration_consent, :boolean, :default => false
    add_index :people, :registration_consent
  end

  def self.down
    remove_column :people, :registration_consent
  end
end
