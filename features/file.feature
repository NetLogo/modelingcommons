Feature: Files

As a user,
I want to associate one or more files with a model
So that the model can be included in a curriculum or have input data

  Background:
    Given a user named "Reuven" "Lerner" with e-mail address "reuven@lerner.co.il" and password "password"
      And a NetLogo model named "Test model"

  Scenario: Users who are not logged in can go to the "file" tab
    When I go to the "files" tab for "Test model"
    Then I should see "No files"

  Scenario: Users who are logged in can go to the "file" tab, and add a file
   Given I log in as "reuven@lerner.co.il" with password "password"
    When I go to the "files" tab for "Test model"
    Then I should see "No files"
     And I should see "Add or update a file"

