Factory.define(:node) do |node|
  node.sequence(:name) { |n| "model#{n}"}
  node.node_type_id 1
  node.visibility_id 1
  node.changeability_id 1
end

Factory.define(:node_version) do |nv|
  nv.association :node
  nv.association :person
  nv.description "Test description"
  nv.file_contents "foo"
end

Factory.define(:permission_setting) do |p|
  p.name "Permission"
  p.short_form "x"
end
