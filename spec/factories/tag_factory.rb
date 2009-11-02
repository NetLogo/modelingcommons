Factory.define(:tag) do |tag|
  tag.sequence(:name) { |n| "tag#{n}"}
  tag.association :person
end

Factory.define(:tagged_nodes) do |tn|
  tn.association :node
  tn.association :tag
  tn.association :person
  tn.sequence(:comment) { |n| "comment#{n}"}
end
