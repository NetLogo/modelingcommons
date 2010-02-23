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

  Scenario: A user may create a project
    Given a project named "newproject"
    When I go to the project list
    Then I should see "Create a new project"

  Scenario: A user may visit a project
    When I go to the project creation page
     And I fill in "newproject" for "Name of your new project"
     And I press "Create project"
     And I go to the project list
    Then I follow "newproject"
     And I should see "Information about the 'newproject' project"
     And I should see "No models in this project."

  Scenario: A project should indicate that it has a model
   Given a NetLogo model named "Test model" in the project "newproject"
    When I go to the project page for "newproject"
    Then I should see "1 model in this project"

  Scenario: A user should see a link allowing adding to a project
   Given a NetLogo model named "Test model"
    When I go to the model page for "Test model"
    Then I should see "Not part of any project"

  Scenario: A user should see his or her models for adding to a project
   Given a NetLogo model named "Test model"
     And a project named "newproject"
    When I go to the project page for "newproject"
    Then I should see "Add a model to this project:"
     And I should see "Test model"

  Scenario: A user should be able to add a model to a project
   Given a NetLogo model named "Test model"
     And a project named "newproject"
    When I go to the project page for "newproject"
     And I select "Test model" from "model_id"
     And I press "Add model"
    Then I should see "Added model 'Test model' to project 'newproject'"

  Scenario: A user should be able to remove a model from a project
   Given a NetLogo model named "Test model" in the project "newproject"
    When I go to the project page for "newproject"
     And I follow "remove"
     And I should see "Removed model 'Test model' from project 'newproject'"
     And I should see "No models in this project."
