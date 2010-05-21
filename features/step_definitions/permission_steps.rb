Given /^the model "([^\"]*)" is only visible by its authors$/ do |model_name|
  model = Node.find_by_name(model_name)
  model.update_attributes(:visibility_id => 2)
end

Given /^the model "([^\"]*)" is visible by the entire world$/ do |model_name|
  model = Node.find_by_name(model_name)
  model.update_attributes(:visibility_id => 1)
end

Given /^the user "([^\"]*)" is a member of the group "([^\"]*)"$/ do |email_address, group_name|
  user = Person.find_by_email_address(email_address)
  group = Factory.create(:group, :name => group_name)
  Factory.create(:membership, :group => group, :user => user)
end

Given /^the model "([^\"]*)" is only visible by members of the group "([^\"]*)"$/ do |arg1, arg2|
  model = Node.find_by_name(model_name)
  group = Factory.create(:group, :name => group_name)
  model.update_attributes(:group => group,
                          :visibility_id => 3)
end
