class AddIpLocation < ActiveRecord::Migration
  def change
    create_table :ip_address_locations do |t|
      t.string :ip_address
      t.text :location

      t.timestamps
    end

    add_index :ip_address_locations, :ip_address, :unique => true
  end
end
