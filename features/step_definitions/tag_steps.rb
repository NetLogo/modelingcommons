Given /^a tag named "([^\"]*)"$/ do |tag_name|
  @tag = FactoryGirl.create(:tag, :name => tag_name)
end

Given /^a tag named "([^\"]*)" applied to the model "([^\"]*)"$/ do |tag_name, model_name|
  @node = Node.find_by_name(model_name)
  @tag = FactoryGirl.create(:tag, :name => tag_name)
  FactoryGirl.create(:tagged_node, :tag => @tag, :node => @node)
end

Given /^a tag named "([^\"]*)" applied to the model "([^\"]*)" by "([^\"]*)"$/ do |tag_name, model_name, person_email|
  @user = Person.find_by_email_address(person_email)
  @node = Node.find_by_name(model_name)
  @tag = FactoryGirl.create(:tag, :name => tag_name)
  FactoryGirl.create(:tagged_node, :tag => @tag, :node => @node, :person => @user)
end
