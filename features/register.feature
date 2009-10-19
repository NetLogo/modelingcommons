Feature: Registration

As a potential user,
I want to be able to register
So that I can use the Modeling Commons

  Scenario: A user may register with the Modeling Commons
    When I go to the registration page
     And I fill in "Reuven" for "First name"
     And I fill in "Lerner" for "Last name"
     And I fill in "reuven@lerner.co.il" for "E-mail address"
     And I fill in "password" for "Password"
     And I fill in "password" for "Password confirmation"
     And I press "register"
    Then I should see "You are now registered with the Modeling Commons.  We're delighted that you've joined us."
