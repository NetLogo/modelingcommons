Given /^a user named "([^\"]*)" "([^\"]*)" with e-mail address "([^\"]*)" and password "([^\"]*)"$/ do |first_name, last_name, email, password|
  @person = Person.create(:first_name => first_name,
                          :last_name => last_name,
                          :password => password,
                          :email_address => email)
  @person.save!
end
