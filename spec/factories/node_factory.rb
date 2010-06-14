Factory.define(:node) do |node|
  node.sequence(:name) { |n| "name#{n}"}
  node.association :visibility, :factory => :permission_setting
  node.association :changeability, :factory => :permission_setting
end
