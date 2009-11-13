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

  Scenario: The default tag comment should be considered empty
    When I go to the "tags" tab for "Test model"
     And I fill in "mytag" for "new_tag_"
     And I fill in "(Optional) comment about why this tag is relevant to this model" for "new_comment_"
     And I press "Save tags to the Commons"
    Then I should see /mytag\s+by\s+You/

  Scenario: A user's tag should appear on the home page
    When I go to the "tags" tab for "Test model"
     And I fill in "mytag" for "new_tag_"
     And I fill in "mycomment" for "new_comment_"
     And I press "Save tags to the Commons"
     And I go to the home page
    Then I should see "Test model was tagged mytag by You"
     And I should see "You created a new tag, mytag"

  Scenario: Going to the tag index page with no tags should show no tags
    When I go to the tag index page
    Then I should see "Tags"
    Then I should see "No tags have been defined yet."

  Scenario: Going to the tag index page with one tag should show that tag
    Given a tag named "mytag"
    When I go to the tag index page
    Then I should see "Tags"
    Then I should see "mytag"
    And I should see /0\s+models,\s+by\s+0\s+people/

  Scenario: Going to the tag index page with one tagged node should show that tag
    Given a tag named "mytag" applied to the model "Test model"
    When I go to the tag index page
    Then I should see "Tags"
    Then I should see "mytag"
    And I should see /1\s+model,\s+by\s+1\s+person/

  Scenario: Following the link for a never-used tag should show that
    Given a tag named "mytag"
    When I go to the tag index page
    And I follow "mytag"
    Then I should see "One tag: mytag"
    And I should see "This tag has never been used."
    And I should see /Models using this tag:\s*None/
    And I should see /Uses of this tag:\s*None/
    And I should see /People who have used this tag:\s*None/

  Scenario: Going to the tag index page with one tag should show that tag
    Given a tag named "mytag" applied to the model "Test model"
    When I go to the tag index page
    Then I should see "Tags"
    Then I should see "mytag"
    And I should see /1\s+model,\s+by\s+1\s+person/

  Scenario: Following the link for a once-used tag should show information about it
    Given a tag named "mytag" applied to the model "Test model" by "reuven@lerner.co.il"
    When I go to the tag index page
    And I follow "mytag"
    Then I should see "One tag: mytag"
    And I should see "First used less than a minute ago."
    And I should see /Models using this tag:\s*Test model/
    And I should see /Uses of this tag:\s*Test model/
    And I should see /People who have used this tag:\s*Reuven Lerner/

