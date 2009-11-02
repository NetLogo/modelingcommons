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

  Scenario: A user may leave a group
    When I go to the group creation page
     And I fill in "newgroup" for "Name of your new group"
     And I press "Create group"
     And I go to my groups page
     And I follow "leave this group"
    Then I should see "You are not a member of any groups."
