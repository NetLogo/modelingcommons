Feature: Administration

As an administrator,
I want to upload my model
So that other people can interact with it

  Scenario: A regular user may not access admin pages
    Given a user named "Reuven" "Lerner" with e-mail address "reuven@lerner.co.il" and password "password"
    When I log in as "reuven@lerner.co.il" with password "password"
     And I go to the administration page
    Then I should see "Only administrators may visit this URL."

  Scenario: An administrator may access admin pages
    Given an administrator named "Reuven" "Lerner" with e-mail address "reuven@lerner.co.il" and password "password"
    When I log in as "reuven@lerner.co.il" with password "password"
     And I go to the administration page
    Then I should see "Administrative functions"

  Scenario: An administrator gets a link to admin pages from his or her home page
    Given an administrator named "Reuven" "Lerner" with e-mail address "reuven@lerner.co.il" and password "password"
    When I log in as "reuven@lerner.co.il" with password "password"
     And I go to the home page
    And I follow "Admin"
    Then I should see "Administrative functions"
