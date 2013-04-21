Given /^a group named "([^\"]*)"$/ do |group_name|
  @group = FactoryGirl.create(:group, :name => group_name)
end
