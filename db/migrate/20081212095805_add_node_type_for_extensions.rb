class AddNodeTypeForExtensions < ActiveRecord::Migration
  def self.up
    NodeType.create(:name => 'NetLogo extension', :description => "NetLogo extension (written in Java)")
  end

  def self.down
  end
end
