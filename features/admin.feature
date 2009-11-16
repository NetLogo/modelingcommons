Feature: Administration

As an administrator,
I want to upload my model
So that other people can interact with it

  Scenario: A regular user may not access admin pages
    Given a user named "Reuven" "Lerner" with e-mail address "reuven@lerner.co.il" and password "password"
     When I log in as "reuven@lerner.co.il" with password "password"
      And I go to the administration page
     Then I should see "Only administrators may visit this URL."

  Scenario: A regular user does not get an admin link
    Given a user named "Reuven" "Lerner" with e-mail address "reuven@lerner.co.il" and password "password"
     When I log in as "reuven@lerner.co.il" with password "password"
      And I go to the home page
     Then I should not see "Admin"

  Scenario: An administrator may access admin pages
    Given an administrator named "Reuven" "Lerner" with e-mail address "reuven@lerner.co.il" and password "password"
     When I log in as "reuven@lerner.co.il" with password "password"
      And I go to the administration page
     Then I should see "Administrative functions"

  Scenario: A user does get an admin link
    Given an administrator named "Reuven" "Lerner" with e-mail address "reuven@lerner.co.il" and password "password"
     When I log in as "reuven@lerner.co.il" with password "password"
      And I go to the home page
      And I follow "Admin"
     Then I should see "Administrative functions"

  Scenario: An administrator looks at all of the people
    Given an administrator named "Reuven" "Lerner" with e-mail address "reuven@lerner.co.il" and password "password"
     When I log in as "reuven@lerner.co.il" with password "password"
      And I go to the admin all-models page
     Then I should see "Reuven"
      And I should see "Reuven"

  Scenario: An administrator looks at all of the people
    Given an administrator named "Reuven" "Lerner" with e-mail address "reuven@lerner.co.il" and password "password"
     When I log in as "reuven@lerner.co.il" with password "password"
      And I go to the admin all-actions page
     Then I should see "You"
