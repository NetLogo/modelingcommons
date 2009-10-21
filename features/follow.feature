Feature: Following

As a user,
I want to follow certain people, tags, and models
So that I can know when they have been updated

  Background:
    Given a user named "Reuven" "Lerner" with e-mail address "reuven@lerner.co.il" and password "password"
      And a NetLogo model named "amodel"
      And a permission setting named "Everyone" with a short form of "a"

  Scenario: A user may follow a model
    When I log in as "reuven@lerner.co.il" with password "password"
     And I go to the page for "amodel"
     And I follow "Follow activity"
