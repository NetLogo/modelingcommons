Feature: Update model

As a user,
I want to update a model
So that people can enjoy the cool new features that I have added

  Background:
    Given a user named "Reuven" "Lerner" with e-mail address "reuven@lerner.co.il" and password "password"
      And I log in as "reuven@lerner.co.il" with password "password"
      And a NetLogo model named "Test model"

  Scenario: A user may update a model with a newer version
    When I log in as "reuven@lerner.co.il" with password "password"
     And I go to the "upload" tab for "Test model"
     And I attach a model file to "new_version_uploaded_body"
     And I choose "Replace the existing model"
     And I press "Upload model"
    Then the model "Test model" should have 2 versions

  Scenario: Updating a model shows up on the home page
    When I log in as "reuven@lerner.co.il" with password "password"
     And I go to the "upload" tab for "Test model"
     And I attach a model file to "new_version_uploaded_body"
     And I choose "Replace the existing model"
     And I press "Upload model"
     And I go to the home page
    Then I should see "Test model was updated by You less than a minute ago."

  Scenario: A user may give a model with a child
    When I log in as "reuven@lerner.co.il" with password "password"
     And I go to the "upload" tab for "Test model"
     And I attach a model file to "new_version_uploaded_body"
     And I choose "Upload a new child"
     And I press "Upload model"
    Then the model "Test model" should have 1 child
