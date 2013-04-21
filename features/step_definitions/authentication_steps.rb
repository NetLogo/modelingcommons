Given /^a user named "([^\"]*)" "([^\"]*)" with e-mail address "([^\"]*)" and password "([^\"]*)"$/ do |first_name, last_name, email, password|
  @person = FactoryGirl.create(:person,
                               :first_name => first_name,
                               :last_name => last_name,
                               :password => password,
                               :email_address => email,
                               :registration_consent => true)
end

Given /^an administrator named "([^\"]*)" "([^\"]*)" with e-mail address "([^\"]*)" and password "([^\"]*)"$/ do |first_name, last_name, email, password|
  @person = FactoryGirl.create(:person,
                               :first_name => first_name,
                               :last_name => last_name,
                               :password => password,
                               :email_address => email,
                               :administrator => true,
                               :registration_consent => true)
end

When /^I log in as "([^\"]*)" with password "([^\"]*)"$/ do |email, pwd|
  step "I go to the home page"
  step "I fill in \"#{email}\" for \"email_address\""
  step "I fill in \"#{pwd}\" for \"password\""
  step "I press \"Login\""
end
