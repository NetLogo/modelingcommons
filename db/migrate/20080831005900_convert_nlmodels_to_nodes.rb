class ConvertNlmodelsToNodes < ActiveRecord::Migration
  def self.up
    Nlmodel.find(:all).each do |nlmodel|
      node = Node.new(:node_type_id => 1,
                      :parent_id => nil,
                      :name => nlmodel.name,
                      :created_at => nlmodel.created_at,
                      :updated_at => nlmodel.updated_at)
      node.save!

      nlmodel.nlmodel_versions.each do |version|
        NodeVersion.create(:node_id => node.id,
                           :person_id => nlmodel.person_id,
                           :contents => version.contents,
                           :created_at => version.created_at,
                           :updated_at => version.updated_at)
      end
    end
  end

  def self.down
    NodeVersion.delete_all
    Node.delete_all
  end
end
