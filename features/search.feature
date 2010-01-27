Feature: Search through models

As a user,
I want to search through models
To find those that match a particular text string

  Background:
    Given a user named "Reuven" "Lerner" with e-mail address "reuven@lerner.co.il" and password "password"
      And a NetLogo model named "Test model"

  Scenario: Searching for an empty string should not work
    When I log in as "reuven@lerner.co.il" with password "password"
     And I go to the search page
     And I fill in "" for "Enter search term:"
     And I press "Search!"
    Then I should see "You must enter a search term in order to search."

  Scenario: A user should be able to find a model by searching for its name
    When I log in as "reuven@lerner.co.il" with password "password"
     And I go to the search page
     And I fill in "est" for "Enter search term:"
     And I press "Search!"
    Then I should see "Models with 'est' in their name"
     And I should see "Test model"
     And I should see "No matches in author names."
     And I should see "No matches in tag names."
