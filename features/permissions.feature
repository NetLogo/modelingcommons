Feature: Permissions

As a user,
I want my models to have various permissions
So that only certain people may read or write the model

  Background:
    Given a user named "Reuven" "Lerner" with e-mail address "reuven@lerner.co.il" and password "password"
      And a user named "Not" "Author" with e-mail address "nonauthor@lerner.co.il" and password "password"
      And a NetLogo model named "My cool model" uploaded by "reuven@lerner.co.il"

  Scenario: Models that are open to the world may be seen by anonymous users
   Given the model "My cool model" is visible by the entire world
    When I go to the model page for "My cool model"
    Then I should see "My cool model"

  Scenario: Models that are open to the world may be seen by all logged-in users
    When I log in as "nonauthor@lerner.co.il" with password "password"
     And I go to the model page for "My cool model"
    Then I should see "My cool model"

  Scenario: A private model cannot be seen by anonymous users
   Given the model "My cool model" is only visible by its authors
    When I log in as "nonauthor@lerner.co.il" with password "password"
     And I go to the model page for "My cool model"
    Then I should not see "My cool model"

  Scenario: A private model cannot be seen by other users
   Given the model "My cool model" is only visible by its authors
    When I log in as "nonauthor@lerner.co.il" with password "password"
     And I go to the model page for "My cool model"
    Then I should not see "My cool model"

  Scenario: A private model can be seen by its author
   Given the model "My cool model" is only visible by its authors
    When I log in as "reuven@lerner.co.il" with password "password"
     And I go to the model page for "My cool model"
    Then I should see "My cool model"

  Scenario: A group-only model cannot be seen by anonymous users
   Given a group named "mygroup"
     And the user "reuven@lerner.co.il" is a member of the group "mygroup"
     And the model "My cool model" is only visible by members of the group "mygroup"
    When I go to the model page for "My cool model"
    Then I should not see "My cool model"
     And I should see "Only members of the 'mygroup' group may view this model."

  Scenario: A group-only model cannot be seen by logged-in users who are not group members
   Given a group named "mygroup"
     And the user "reuven@lerner.co.il" is a member of the group "mygroup"
     And the model "My cool model" is only visible by members of the group "mygroup"
    When I log in as "nonauthor@lerner.co.il" with password "password"
     And I go to the model page for "My cool model"
    Then I should not see "My cool model"
     And I should see "Only members of the 'mygroup' group may view this model."

  Scenario: A group-only model can be seen by logged-in users who are group members
   Given a group named "mygroup"
     And the user "reuven@lerner.co.il" is a member of the group "mygroup"
     And the model "My cool model" is only visible by members of the group "mygroup"
    When I log in as "reuven@lerner.co.il" with password "password"
     And I go to the model page for "My cool model"
    Then I should see "My cool model"
