Feature: Tagging

As a user,
I want to be able to tag models
So that I can help to connect models in a folksonomy

  Background:
    Given a user named "Reuven" "Lerner" with e-mail address "reuven@lerner.co.il" and password "password"
      And I log in as "reuven@lerner.co.il" with password "password"
      And a NetLogo model named "Test model"

  Scenario: A model should have no tags, by default
    When I go to the "tags" tab for "Test model"
    Then I should see "No tags have been defined for this model."

  Scenario: A user should be able to tag a model
    When I go to the "tags" tab for "Test model"
     And I fill in "mytag" for "new_tag_"
     And I fill in "mycomment" for "new_comment_"
     And I press "Save tags to the Commons"
    Then I should see /mytag\s+mycomment\s+by\s+You/
     And I should see "Existing tags:"
     And I should not see "No tags have been defined for this model."

  Scenario: A user's tag should appear on the home page
    When I go to the "tags" tab for "Test model"
     And I fill in "mytag" for "new_tag_"
     And I fill in "mycomment" for "new_comment_"
     And I press "Save tags to the Commons"
     And I go to the home page
    Then I should see "Test model was tagged mytag by You"
     And I should see "You created a new tag, mytag"
