require 'active_record/fixtures'

class LoadTagsData < ActiveRecord::Migration
  def self.up
    down
    
    directory = File.join(File.dirname(__FILE__), "dev_data")
    Fixtures.create_fixtures(directory, "tags")
  end

  def self.down
    Tag.delete_all
  end
end
