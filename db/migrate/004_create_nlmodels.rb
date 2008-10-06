class CreateNlmodels < ActiveRecord::Migration
  def self.up
    create_table :nlmodels do |t|
      t.string :name
      t.text :contents

      t.timestamps
    end
  end

  def self.down
    drop_table :nlmodels
  end
end
