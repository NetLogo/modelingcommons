Feature: Projects

As a user,
I want to be able to create and join projects
So that I can create subsets of the Modeling Commons community

  Background:
    Given a user named "Reuven" "Lerner" with e-mail address "reuven@lerner.co.il" and password "password"
      And I log in as "reuven@lerner.co.il" with password "password"

  Scenario: A user may create a project
    When I go to the project creation page
     And I fill in "newproject" for "Name of your new project"
     And I press "Create project"
    Then I should see "Successfully created the project 'newproject'"

  Scenario: A user may visit a project
    When I go to the project creation page
     And I fill in "newproject" for "Name of your new project"
     And I press "Create project"
     And I go to the project list
    Then I follow "newproject"
     And I should see "Information about the 'newproject' project"
     And I should see "No models in this project."
