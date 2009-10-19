Feature: Password reminder

As a forgetful user,
I need to get a password reminder e-mailed to me
So that I can log in

  Background:
    Given a user named "Reuven" "Lerner" with e-mail address "reuven@lerner.co.il" and password "password"

  Scenario: Password reminder page should work
    When I go to the password reminder page
    Then I should see "Send password reminder"

  Scenario: Get password reminder for a real address
    When I go to the password reminder page
     And I fill in "reuven@lerner.co.il" for "E-mail address"
     And I press "Send password reminder"
    Then I should see "A password reminder was sent to your e-mail address."

  Scenario: Get password reminder for an unregistered address
    When I go to the password reminder page
     And I fill in "reuvennnn@lernerrrr.coooo.illll" for "E-mail address"
     And I press "Send password reminder"
    Then I should see "Sorry, but 'reuvennnn@lernerrrr.coooo.illll' is not listed in our system.  Please register."

