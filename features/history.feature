Feature: Work with older versions

As a user,
I want to work with versions of a model
To examine changes that occurred over time

  Background:
    Given a user named "Reuven" "Lerner" with e-mail address "reuven@lerner.co.il" and password "password"
      And a NetLogo model named "Test model"

  Scenario: If the model has only one version, then no version commands should be available
    When I log in as "reuven@lerner.co.il" with password "password"
     And I go to the "history" tab for "Test model"
    Then I should see /There is only one version of this model, created\s+less than a minute ago\s+by You./
     And I should not see "Download this version"

  Scenario: If the model has two versions, then the table show show that
   Given 1 additional version of "Test model"
    When I log in as "reuven@lerner.co.il" with password "password"
     And I go to the "history" tab for "Test model"
    Then I should see "There are 2 versions of this model."
     And I should see "Download this version"

  Scenario: If the model has 3 versions, then there should be a total of 4 shown
   Given 3 additional versions of "Test model"
    When I log in as "reuven@lerner.co.il" with password "password"
     And I go to the "history" tab for "Test model"
    Then I should see "There are 4 versions of this model."
     And I should see "Download this version"

  Scenario: If the user does not select a version for comparison, we're sent back
   Given 1 additional version of "Test model"
    When I log in as "reuven@lerner.co.il" with password "password"
     And I go to the "history" tab for "Test model"
     And I press "Compare selected versions"
    Then I should be on the "history" tab for "Test model"

  Scenario: The user compares two model versions
   Given 1 additional version of "Test model"
    When I log in as "reuven@lerner.co.il" with password "password"
     And I go to the "history" tab for "Test model"
     And I choose "compare_1" for version 1
     And I choose "compare_2" for version 2
     And I press "Compare selected versions"
    Then I should see "No differences in the Info tab"
     And I should see "No differences in the Procedures tab"

  Scenario: The user compares the same model version
   Given 1 additional version of "Test model"
    When I log in as "reuven@lerner.co.il" with password "password"
     And I go to the "history" tab for "Test model"
     And I choose "compare_1" for version 1
     And I choose "compare_2" for version 1
     And I press "Compare selected versions"
    Then I should be on the "history" tab for "Test model"

  Scenario: The user compares two radically difference versions of the same model
   Given a version of "Test model" with different content
    When I log in as "reuven@lerner.co.il" with password "password"
     And I go to the "history" tab for "Test model"
     And I choose "compare_1" for version 1
     And I choose "compare_2" for version 2
     And I press "Compare selected versions"
    Then I should not see "No differences in the Info tab"
     And I should see "No differences in the Procedures tab"
