Given /^a user named "([^\"]*)" "([^\"]*)" with an e-mail address "([^\"]*)"$/ do |first_name, last_name, email|
  @person = Person.create(:first_name => first_name,
                          :last_name => last_name,
                          :password => 'password',
                          :email_address => email)
  @person.save!
end
