require File.expand_path(Rails.root + 'spec/factories/factories')

Given /^a user named "([^\"]*)" "([^\"]*)" with e-mail address "([^\"]*)" and password "([^\"]*)"$/ do |first_name, last_name, email, password|
  @person = Factory.create(:person,
                           :first_name => first_name,
                           :last_name => last_name,
                           :password => password,
                           :email_address => email,
                           :registration_consent => true)
end

Given /^an administrator named "([^\"]*)" "([^\"]*)" with e-mail address "([^\"]*)" and password "([^\"]*)"$/ do |first_name, last_name, email, password|
  @person = Factory.create(:person,
                           :first_name => first_name,
                           :last_name => last_name,
                           :password => password,
                           :email_address => email,
                           :administrator => true,
                           :registration_consent => true)
end

When /^I log in as "([^\"]*)" with password "([^\"]*)"$/ do |email, pwd|
  When "I go to the home page"
  And "I fill in \"#{email}\" for \"email_address\""
  And "I fill in \"#{pwd}\" for \"password\""
  And "I press \"Login\""
end
