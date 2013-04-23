Feature: Password reset

As a forgetful user,
I need to get my password reset
So that I can log in

  Background:
    Given a user named "Reuven" "Lerner" with e-mail address "reuven@lerner.co.il" and password "password"

  Scenario: Password reset page should work
    When I go to the password reset page
    Then I should see "Reset password"

  @javascript
  Scenario: Get password reset for a real address
    When I go to the password reset page
     And I fill in "reuven@lerner.co.il" for "email_address" within "p.password-reset"
     And I press "Reset password"
    Then I should see "Your password has been reset. The new password was sent to your e-mail address."

  @javascript
  Scenario: Get password reset for an illegal address
    When I go to the password reset page
     And I fill in "notemail" for "email_address" within "p.password-reset"
     And I press "Reset password"
    Then I should see "'notemail' is not a valid e-mail address."

  @javascript
  Scenario: Get password reset for a blank address
    When I go to the password reset page
     And I fill in "" for "email_address" within "p.password-reset"
     And I press "Reset password"
    Then I should see "'' is not a valid e-mail address"

  @javascript
  Scenario: Trying to go to the send_password_action page results in a message
    When I go to the password reset action page
    Then I should see "'' is not a valid e-mail address."
