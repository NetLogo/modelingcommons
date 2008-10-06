class CreateLoggedActions < ActiveRecord::Migration
  def self.up
    create_table :logged_actions do |t|
      t.column :person_id, :integer
      t.column :logged_at, :datetime
      t.column :message, :text
      t.column :ip_address, :string
      t.column :browser_info, :string
      t.column :url, :string
      t.column :params, :string
      t.column :session, :text
      t.column :cookies, :text
      t.column :flash, :text
    end
  end

  def self.down
    drop_table :logged_actions
  end
end
