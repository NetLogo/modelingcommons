class AddInfoFieldsToPerson < ActiveRecord::Migration
  def change
    add_column :people, :url, :string
    add_column :people, :biography, :text
    add_column :people, :show_email_address, :boolean, :default => false
  end
end
