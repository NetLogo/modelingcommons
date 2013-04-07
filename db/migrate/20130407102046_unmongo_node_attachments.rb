class UnmongoNodeAttachments < ActiveRecord::Migration
  def self.up
    rename_column :attachments, :type, :content_type

    number_of_node_attachments = NodeAttachment.count
    Node.transaction do 
      NodeAttachment.all.each_with_index do |na, index|
        STDERR.puts "#{index} / #{number_of_node_attachments}"
        STDERR.puts "\tNodeAttachment ID '#{na.id}'"
        STDERR.puts "\tNodeAttachment type '#{na.type}'"
        STDERR.puts "\tNodeAttachment ID '#{na.inspect}'" 
        
        Attachment.create!(:person_id => na.person_id,
                           :node_id => na.node_id,
                           :contents => na.contents.to_s,
                           :description => na.description,
                           :filename => na.filename,
                           :content_type => na.type,
                           :created_at => na.created_at,
                           :updated_at => na.updated_at)
      end
    end
  end

  def self.down
  end
end
