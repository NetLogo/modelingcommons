Given /^a group named "([^\"]*)"$/ do |group_name|
  Factory.create(:group, :name => group_name)
end
