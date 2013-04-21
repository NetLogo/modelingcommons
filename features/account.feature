Feature: Account

As a user,
I want to be able to edit my account
So that I can change my name frequently

  Background:
    Given a user named "Reuven" "Lerner" with e-mail address "reuven@lerner.co.il" and password "password"
      And I log in as "reuven@lerner.co.il" with password "password"

  Scenario: You should be able to go to the "Edit your profile" page when logged in
    When I go to the home page
     And I follow "Edit your details"
    Then I should see "Edit your profile"

  Scenario: You should be able to change your first and last name
    When I go to the home page
     And I follow "Edit your details"
     And I fill in "BlahFirst" for "First name"
     And I fill in "BlahLast" for "Last name"
     And I fill in "password" for "Password"
     And I fill in "password" for "Password confirmation"
     And I press "Update account"
    Then I should see "Successfully updated your account."
     And I should see "Hello BlahFirst BlahLast"

  Scenario: You should not be able to change your first and last name without a password
    When I go to the home page
     And I follow "Edit your details"
     And I fill in "BlahFirst" for "First name"
     And I fill in "BlahLast" for "Last name"
     And I fill in "password111" for "Password"
     And I fill in "password222" for "Password confirmation"
     And I press "Update account"
    Then I should see "Error updating your account: 'Validation failed: Password doesn't match confirmation'"

  Scenario: You should be able to change your password
    When I go to the home page
     And I follow "Edit your details"
     And I fill in "password111" for "Password"
     And I fill in "password111" for "Password confirmation"
     And I press "Update account"
    Then I should see "Successfully updated your account."

