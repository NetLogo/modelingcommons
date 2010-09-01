Feature: Discussion

As a user,
I want to be able to discuss models
So that I can connect with others and learn from them

  Background:
    Given a user named "Reuven" "Lerner" with e-mail address "reuven@lerner.co.il" and password "password"
      And I log in as "reuven@lerner.co.il" with password "password"
      And a NetLogo model named "Test model"

  Scenario: A model should have no dicussion, by default
    When I go to the "discuss" tab for "Test model"
    Then I should see "Please start the conversation about this model."

  Scenario: A logged-in user can submit a comment
    When I go to the "discuss" tab for "Test model"
     And I fill in "comment title" for "Title"
     And I fill in "comment body" for "Body"
     And I press "Submit comment"
    Then I should see /You,\s*less than a minute ago/
    And I should see "comment title"
    And I should see "comment body"
    And I should see "Delete"

  Scenario: A logged-in user can submit a comment without a title
    When I go to the "discuss" tab for "Test model"
     And I fill in "comment body" for "Body"
     And I press "Submit comment"
    Then I should see /You,\s*less than a minute ago/
    And I should see "comment title"
    And I should see "comment body"
    And I should see "Delete"

  Scenario: A logged-in user can submit a question
    When I go to the "discuss" tab for "Test model"
     And I fill in "question title" for "Title"
     And I fill in "question body" for "Body"
     And I check "This is a question that I would like answered"
     And I press "Submit comment"
     And I go to the home page
    Then I should see /You asked about\s+'question title,' less than a minute ago/

  Scenario: A logged-in user can delete their own comment
    Given a comment with with title "comment title" and body "comment body" for model "Test model" by user "reuven@lerner.co.il"
    When I go to the "discuss" tab for "Test model"
    And I follow "Delete"
    Then I should see "Posting deleted"

  Scenario: A logged-in user can undelete their own comment
    Given a comment with with title "comment title" and body "comment body" for model "Test model" by user "reuven@lerner.co.il"
    When I go to the "discuss" tab for "Test model"
    And I follow "Delete"
    And I go to the "discuss" tab for "Test model"
    And I follow "Undelete"
    Then I should see "Posting undeleted"

  Scenario: A logged-in user can indicate that a question was answered
    Given a question with with title "comment title" and body "comment body" for model "Test model" by user "reuven@lerner.co.il"
    When I go to the "discuss" tab for "Test model"
    And I follow "Mark as answered"
    Then I should see "Question marked as answered"

  Scenario: A logged-in user can indicate that a question was unanswered
    Given a question with with title "comment title" and body "comment body" for model "Test model" by user "reuven@lerner.co.il"
    When I go to the "discuss" tab for "Test model"
    And I follow "Mark as answered"
    When I go to the "discuss" tab for "Test model"
    And I follow "Mark as unanswered"
    Then I should see "Question marked as unanswered"
