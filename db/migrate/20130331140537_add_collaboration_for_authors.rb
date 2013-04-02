class AddCollaborationForAuthors < ActiveRecord::Migration
  def self.up
    author_collaborator = CollaboratorType.find_by_name("Author")
    total_nodes = Node.count
    Node.all.each_with_index do |n, n_index|
      STDERR.puts "[#{n_index} / #{total_nodes}]"

      old_people = n.node_versions.map {|version| version.person}.uniq

      total_people = old_people.size
      old_people.each_with_index do |p, p_index|
        STDERR.puts "\t#{p_index} / #{total_people}"
        Collaboration.create!(:node => n,
                              :person => p,
                              :collaborator_type => author_collaborator)
      end
    end
  end

  def self.down
  end
end
