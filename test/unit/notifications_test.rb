require File.dirname(__FILE__) + '/../test_helper'

class NotificationsTest < ActionMailer::TestCase
  tests Notifications
  def test_signup
    @expected.subject = 'Notifications#signup'
    @expected.body    = read_fixture('signup')
    @expected.date    = Time.now

    assert_equal @expected.encoded, Notifications.create_signup(@expected.date).encoded
  end

  def test_reset_password
    @expected.subject = 'Notifications#reset_password'
    @expected.body    = read_fixture('reset_password')
    @expected.date    = Time.now

    assert_equal @expected.encoded, Notifications.create_reset_password(@expected.date).encoded
  end

end
