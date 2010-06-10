Factory.define(:node_type) do |node_type|
  node_type.sequence(:name) { |n| "node_type#{n}"}
  node_type.sequence(:description) { |n| "description#{n}"}
end
