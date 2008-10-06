require 'active_record/fixtures'

class LoadModelsData < ActiveRecord::Migration
  def self.up
    down
    
    directory = File.join(File.dirname(__FILE__), "dev_data")
    Fixtures.create_fixtures(directory, "models")
  end

  def self.down
    Model.delete_all
  end
end
