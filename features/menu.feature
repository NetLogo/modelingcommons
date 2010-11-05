Feature: Menus

As a user,
I should see certain menu options without logging in,
and even more menu options when I am not logged in.

  Background:
    Given a user named "Reuven" "Lerner" with e-mail address "reuven@lerner.co.il" and password "password"

  Scenario: Guest users who go to the home page should see a restricted menu
    When I go to the home page
    Then I should see "Modeling Commons"
    And I should see "Welcome to the Modeling Commons!"
    And I should see "Home"
    And I should see "List models"
    And I should see "Help"
    And I should not see "Add model"
    And I should not see "Groups"
    And I should not see "Projects"
    And I should not see "Tags"

  Scenario: Users who go to the home page should be asked to log in
    Given I log in as "reuven@lerner.co.il" with password "password"
    When I go to the home page
    Then I should see "Modeling Commons"
    And I should see "Home"
    And I should see "List models"
    And I should see "Help"
    And I should see "Add model"
    And I should see "Groups"
    And I should see "Projects"
    And I should see "Tags"

  Scenario: Users can go to the "List models" page
    When I go to the list-models page
    Then I should see "List of models"

  Scenario: Guest users cannot go to the "upload a model" page
    When I go to the list-models page
    Then I should not see "Upload a new model"

  Scenario: Logged in users can go to the "upload a model" page
    When I log in as "reuven@lerner.co.il" with password "password"
    And I go to the list-models page
    And I follow "Upload a new model"
    Then I should see "Upload a NetLogo model"

  Scenario: Guest users cannot go to the "Add model" page
    When I go to the upload page
    Then I should see "You must log in before proceeding."

  Scenario: Logged-in users can go to the "Add model" page
    When I log in as "reuven@lerner.co.il" with password "password"
    And I go to the upload page
    Then I should see "Upload a NetLogo model"

  Scenario: Users can go to the "Groups" page
    When I go to the groups page
    Then I should see "Groups"

  Scenario: Guest users cannot go to the "Add model" page
    When I go to the tags page
    Then I should see "You must log in before proceeding."

  Scenario: Users can go to the "Tags" page
    When I log in as "reuven@lerner.co.il" with password "password"
    And I go to the tags page
    Then I should see "Tags you created"
    And I should see "Tags you applied"

  Scenario: Users can go to the "Help" page
    When I go to the help page
    Then I should see "Modeling Commons help"

  Scenario: Users can go to the "Screencasts" page
    When I go to the screencasts page
    Then I should see "Screencasts"

