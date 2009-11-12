Feature: Menus

As a user,
I should see certain menu options without logging in,
and even more menu options when I am not logged in.

  Background:
    Given a user named "Reuven" "Lerner" with e-mail address "reuven@lerner.co.il" and password "password"

  Scenario: Guest users who go to the home page should see a restricted menu
    When I go to the home page
    Then I should see "Modeling Commons"
    And I should see "You must first log in"
    And I should see "Home"
    And I should see "List models"
    And I should see "About"
    And I should see "Help"
    And I should not see "Add model"
    And I should not see "Groups"
    And I should not see "Tags"

  Scenario: Users who go to the home page should be asked to log in
    Given I log in as "reuven@lerner.co.il" with password "password"
    When I go to the home page
    Then I should see "Modeling Commons"
    And I should see "Home"
    And I should see "List models"
    And I should see "About"
    And I should see "Help"
    And I should see "Add model"
    And I should see "Groups"
    And I should see "Tags"

  Scenario: Users can go to the "About" page
    When I go to the about page
    Then I should see "About the Modeling Commons"

  Scenario: Users can go to the "Help" page
    When I go to the help page
    Then I should see "Modeling Commons help"

  Scenario: Users can go to the "Screencasts" page
    When I go to the screencasts page
    Then I should see "Screencasts"
