Feature: Groups

As a user,
I want to be able to create and join groups
So that I can create subsets of the Modeling Commons community

  Background:
    Given a user named "Reuven" "Lerner" with e-mail address "reuven@lerner.co.il" and password "password"
      And I log in as "reuven@lerner.co.il" with password "password"

  Scenario: A user should have no groups, by default
    When I go to my groups page
    Then I should see "You are not a member of any groups."

  Scenario: A user may create a group
    When I go to the group creation page
     And I fill in "newgroup" for "Name of your new group"
     And I press "Create group"
    Then I should see "Successfully created the group 'newgroup'."

  Scenario: A user may visit a group
    When I go to the group creation page
     And I fill in "newgroup" for "Name of your new group"
     And I press "Create group"
     And I go to my groups page
    Then I follow "newgroup"
     And I should see "Group info for 'newgroup'"
     And I should see "No models."

  Scenario: A user may leave a group
    When I go to the group creation page
     And I fill in "newgroup" for "Name of your new group"
     And I press "Create group"
     And I go to my groups page
     And I follow "leave this group"
    Then I should see "You are not a member of any groups."

  Scenario: A user may go to the group finding page
    When I go to the group finding page
    Then I should see "Group name to search for:"

  Scenario: A user may search for a group that does not exist
    When I go to the group finding page
     And I fill in "newgroup" for "Group name to search for"
     And I press "Find"
    Then I should see "No groups contain 'newgroup'. Please try again."

  Scenario: A user may search for a group that does not exist
   Given a group named "newgroup"
    When I go to the group finding page
     And I fill in "newgroup" for "Group name to search for"
     And I press "Find"
    Then I should see "newgroup"
