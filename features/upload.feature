Feature: Upload model

As a user,
I want to upload my model
So that other people can interact with it

  Background:
    Given a user named "Reuven" "Lerner" with e-mail address "reuven@lerner.co.il" and password "password"

  Scenario: A user may upload a NetLogo model
    When I log in as "reuven@lerner.co.il" with password "password"
     And I go to the upload page
    Then I should see "Upload a NetLogo model"
