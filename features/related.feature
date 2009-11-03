Feature: Related

As a user,
I want to know which models are related to the current one
So that I can explore families of models

  Background:
    Given a user named "Reuven" "Lerner" with e-mail address "reuven@lerner.co.il" and password "password"
      And a NetLogo model named "Test model"

  Scenario: Users who go to the related tab should not see any family
    When I go to the "related" tab for "Test model"
    Then I should see "This model does not have any ancestors."
     And I should see "This model does not have any descendants."

  Scenario: We should be able to get a graph for our model
    When I go to the related graph for "Test model"
    Then I should not see "This model does not have any descendants."
