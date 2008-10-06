class AddLotsOfIndexes < ActiveRecord::Migration
  def self.up
    add_index :logged_actions, :person_id
    add_index :logged_actions, :url
    add_index :logged_actions, :ip_address

    add_index :nlmodels, :name
    add_index :nlmodels, :person_id
    add_index :nlmodels, :created_at
    add_index :nlmodels, :updated_at

    add_index :nlmodel_versions, :nlmodel_id
    add_index :nlmodel_versions, :person_id
    add_index :nlmodel_versions, :created_at
    add_index :nlmodel_versions, :updated_at

    add_index :people, :email_address
    add_index :people, :first_name
    add_index :people, :last_name

    add_index :postings, :person_id
    add_index :postings, :nlmodel_id
    add_index :postings, :title
    add_index :postings, :body
    add_index :postings, :created_at
    add_index :postings, :updated_at
    add_index :postings, :parent_id
  end

  def self.down
  end
end
