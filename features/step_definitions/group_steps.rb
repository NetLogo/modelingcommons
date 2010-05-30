Given /^a group named "([^\"]*)"$/ do |group_name|
  @group = Factory.create(:group, :name => group_name)
end
