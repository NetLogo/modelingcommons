Given /^a project named "([^\"]*)"$/ do |project_name|
  FactoryGirl.create(:project, :name => project_name)
end
