Given /^a project named "([^\"]*)"$/ do |project_name|
  Factory.create(:project, :name => project_name)
end
