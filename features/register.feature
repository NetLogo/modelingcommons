Feature: Registration

As a potential user,
I want to be able to register
So that I can use the Modeling Commons

  Scenario: A user may register with the Modeling Commons
    When I go to the registration page
     And I fill in "Reuven" for "First name"
     And I fill in "Lerner" for "Last name"
     And I fill in "reuven@lerner.co.il" for "E-mail address"
     And I fill in "password" for "new_person_password"
     And I fill in "password" for "new_person_password_confirmation"
     And I choose "Male"
     And I check "I understand and agree to the above."
     And I press "Register"
    Then I should see "Hello Reuven Lerner"
