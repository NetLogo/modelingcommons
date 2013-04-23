Feature: Tagging

As a user,
I want to be able to tag models
So that I can help to connect models in a folksonomy

  Background:
    Given a user named "Reuven" "Lerner" with e-mail address "reuven@lerner.co.il" and password "password"
      And I log in as "reuven@lerner.co.il" with password "password"
      And a NetLogo model named "Test model" uploaded by "reuven@lerner.co.il"

  Scenario: A model should have no tags, by default
    When I go to the model page for "Test model"
    Then I should see "No tags have been added to this model"

  @javascript
  Scenario: A user should be able to tag a model
    When I go to the model page for "Test model"
     And I follow "Add tag"
     And I fill in "mytag" for "new_tag_"
     And I fill in "mycomment" for "new_comment_"
     And I press "Tag this model"
    Then I wait to see "mytag"
     And I should not see "No tags have been defined for this model."

  @javascript
  Scenario: A user's tag should appear on the home page
    When I go to the model page for "Test model"
     And I follow "Add tag"
     And I fill in "mytag" for "new_tag_"
     And I fill in "mycomment" for "new_comment_"
     And I press "Tag this model"
     And I go to the home page
    Then I should see "You added tag mytag to Test model"
     And I should see "You created tag mytag"

  Scenario: Going to the tag index page with no tags should show no tags
    When I go to the tag index page
    Then I should see "Tags"
    Then I should see "No tags have been defined yet."

  Scenario: Going to the tag index page with one tag should show that tag
    Given a tag named "mytag" applied to the model "Test model" by "reuven@lerner.co.il"
    When I go to the tag index page
    Then I should see "Tags"
    Then I should see "mytag"
     And I should see "(Applied to Test model)"

  Scenario: Following the link for a once-used tag should show information about it
    Given a tag named "mytag" applied to the model "Test model" by "reuven@lerner.co.il"
    When I go to the tag index page
    And I follow "mytag"
    Then I should see "One tag: mytag"
    And I should see "First used less than a minute ago."
    And I should see /Models using this tag:\s*Test model/
    And I should see /People who have used this tag:\s*Reuven Lerner/
