Feature: Login

As a user,
I want to be able to log in
So that I can use the system

  Background:
    Given a user named "Reuven" "Lerner" with e-mail address "reuven@lerner.co.il" and password "password"

  Scenario: Users who go to the home page are asked to log in
    When I go to the home page
    Then I should see "Modeling Commons"
    And I should see "Welcome to the Modeling Commons!"

  Scenario: Users can log in by entering their name and e-mail address
    When I log in as "reuven@lerner.co.il" with password "password"
    Then I should see "Welcome back to the Commons, Reuven!"

  Scenario: Entering a bad username should produce a warning message
    When I log in as "reuvennnnn@lernerrrrr.coooo.illll" with password "password"
    Then I should see "Sorry, but no user exists with that e-mail address and password. Please try again."
     And I should not see "Welcome back to the Commons, Reuven!"

  Scenario: Entering a bad password should produce a warning message
    When I log in as "reuven@lerner.co.il" with password "badbadpasspass"
    Then I should see "Sorry, but no user exists with that e-mail address and password. Please try again."
     And I should not see "Welcome back to the Commons, Reuven!"

  Scenario: Entering a blank username should produce a warning message
    When I log in as "" with password "password"
    Then I should see "You must provide an e-mail address and password in order to log in."
     And I should not see "Welcome back to the Commons, Reuven!"

  Scenario: Entering a blank password should produce a warning message
    When I log in as "reuven@lerner.co.il" with password ""
    Then I should see "You must provide an e-mail address and password in order to log in."
     And I should not see "Welcome back to the Commons, Reuven!"

  Scenario: Log out
    When I log in as "reuven@lerner.co.il" with password "password"
     And I follow "Logout"
    Then I should see "You have been logged out. Please come back soon!"

  Scenario: Edit account information
    When I log in as "reuven@lerner.co.il" with password "password"
     And I follow "Edit personal details"
     And I fill in "NewFirstname" for "First name"
     And I fill in "NewLastname" for "Last name"
     And I fill in "newpw" for "Password"
     And I fill in "newpw" for "Password confirmation"
     And I press "Update account"
    Then I should see "Successfully updated your account."

  Scenario: Trying to go to the login_action page results in a message
    When I go to the login action page
    Then I should see "You must provide an e-mail address and password in order to log in."
