class UnmongoNodeVersions < ActiveRecord::Migration
  def self.up
    number_of_nodeversions = NodeVersion.count
    Node.transaction do 
      NodeVersion.all.each_with_index do |nv, index|
        STDERR.puts "#{index} / #{number_of_nodeversions}"
        
        Version.create!(:person_id => nv.person_id,
                        :node_id => nv.node_id,
                        :contents => nv.contents,
                        :description => nv.description,
                        :created_at => nv.created_at,
                        :updated_at => nv.updated_at)
      end
    end
  end

  def self.down
  end
end
