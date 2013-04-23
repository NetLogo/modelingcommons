When /^I wait to see "([^\"]*)"/ do |content|
  page.should have_content(content)
end

When "I wait" do 
  sleep 10
end

When /^I select the "([^\"]*)" tab for "([^\"]*)"/ do |tab_name, model_name|
  step "I go to the model page for \"#{model_name}\""
  step "I follow \"Upload\""
end
