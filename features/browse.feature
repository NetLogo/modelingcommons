Feature: Browse models

As a user,
I want to browse through a model
To learn, as well as share and collaborate with others

  Background:
    Given a user named "Reuven" "Lerner" with e-mail address "reuven@lerner.co.il" and password "password"
      And a NetLogo model named "Test model"

  Scenario: A user should be able to view the model page without logging in
    When I log in as "reuven@lerner.co.il" with password "password"
     And I go to the model page for "Test model"
    Then I should see "Test model"
     And I should see "Follow 'Test model' in your reader"

  Scenario: A user should be able to view the model page with logging in
    When I go to the model page for "Test model"
    Then I should see "Test model"
     And I should see "Follow 'Test model' in your reader"

  Scenario Outline: Try each of the tabs for the model when not logged in
    When I go to the "<tab_name>" tab for "Test model"
    Then I should see "Return to page for the 'Test model' model"

  Scenarios: Different tabs
    | tab_name    |
    | preview     |
    | applet      |
    | info        |
    | procedures  |
    | download    |
    | discuss     |
    | history     |
    | tags        |
    | files       |
    | related     |
    | upload      |
    | permissions |

  Scenario Outline: Try each of the tabs for the model when I am logged in
    When I log in as "reuven@lerner.co.il" with password "password"
     And I go to the "<tab_name>" tab for "Test model"
    Then I should see "Return to page for the 'Test model' model"

  Scenarios: Different tabs
    | tab_name    |
    | preview     |
    | applet      |
    | info        |
    | procedures  |
    | download    |
    | discuss     |
    | history     |
    | tags        |
    | files       |
    | related     |
    | upload      |
    | permissions |

