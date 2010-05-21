Factory.define(:node) do |node|
  node.name "node"
  node.node_type_id 1

  node.association :visibility, :factory => :permission_setting
  node.association :changeability, :factory => :permission_setting
end

Factory.define(:node_version) do |nv|
  nv.association :node
  nv.association :person
  nv.description "Test description"
  nv.file_contents File.open(RAILS_ROOT + "/features/upload_files/test.nlogo").readlines.join("\n")
end
