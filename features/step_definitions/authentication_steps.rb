Given /^a user named "([^\"]*)" "([^\"]*)" with e-mail address "([^\"]*)" and password "([^\"]*)"$/ do |first_name, last_name, email, password|
  encrypted_password = Person.encrypted_password('salt', password)

  @person = FactoryGirl.create(:person,
                               :first_name => first_name,
                               :last_name => last_name,
                               :password => encrypted_password,
                               :email_address => email,
                               :registration_consent => true)
end

Given /^an administrator named "([^\"]*)" "([^\"]*)" with e-mail address "([^\"]*)" and password "([^\"]*)"$/ do |first_name, last_name, email, password|
  encrypted_password = Person.encrypted_password('salt', password)

  @person = FactoryGirl.create(:person,
                               :first_name => first_name,
                               :last_name => last_name,
                               :password => encrypted_password,
                               :email_address => email,
                               :administrator => true,
                               :registration_consent => true)
end

When /^I log in as "([^\"]*)" with password "([^\"]*)"$/ do |email, pwd|
  first_name = Person.find_by_email_address(email).first_name

  step "I go to the home page"
  step "I fill in \"#{email}\" for \"email_address\""
  step "I fill in \"#{pwd}\" for \"password\""
  step "I press \"Login\""
  step "I should see \"Hello #{first_name}\""
end
