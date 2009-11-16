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
