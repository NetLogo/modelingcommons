Factory.define(:project) do |project|
  project.sequence(:name) { |n| "tag#{n}"}
end
