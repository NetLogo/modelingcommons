Feature: Home page

As a user,
I want to be able to log in
So that I can use the system

    Scenario: Users who go to the home page are asked to log in
      Given a user named "Reuven" "Lerner" with an e-mail address "reuven@lerner.co.il"
      When I go to the home page
      Then I should see "Modeling Commons"
      And I should see "You must first log in"

    Scenario: Users can log in by entering their name and e-mail address
      Given a user named "Reuven" "Lerner" with an e-mail address "reuven@lerner.co.il"
      When I go to the home page
       And I fill in "reuven@lerner.co.il" for "email_address"
       And I fill in "password" for "password"
       And I press "submit"
      Then I should see "Welcome back to the Commons, Reuven!"
