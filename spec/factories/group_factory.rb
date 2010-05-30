Factory.define(:group) do |group|
  group.sequence(:name) { |n| "tag#{n}"}
end

Factory.define(:membership) do |m|
  m.association :person
  m.association :group
  m.is_administrator false
  m.status "pending"
end
