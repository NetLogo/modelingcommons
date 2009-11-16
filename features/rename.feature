Feature: Rename a model

As a user,
I want to rename a model
So it will not have a silly name

  Background:
    Given a user named "Reuven" "Lerner" with e-mail address "reuven@lerner.co.il" and password "password"
      And a NetLogo model named "Test model"

  Scenario: A user should be scolded if they enter nothing
    When I log in as "reuven@lerner.co.il" with password "password"
     And I go to the model page for "Test model"
     And I follow "Rename this model"
     And I fill in "" for "new_name"
     And I press "Rename model"
    Then I should be on the rename page for "Test model"
     And I should see "You must enter a new name for the model."

  Scenario: A user should be able to rename the model
    When I log in as "reuven@lerner.co.il" with password "password"
     And I go to the model page for "Test model"
     And I follow "Rename this model"
     And I fill in "Slartibartfast" for "new_name"
     And I press "Rename model"
    Then I should be on the model page for "Slartibartfast"
     And I should see "Slartibartfast"
     And I should see "Successfully renamed the model to 'Slartibartfast'."

