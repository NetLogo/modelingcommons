When /^I wait to see "([^\"]*)"/ do |content|
  page.should have_content(content)
end
