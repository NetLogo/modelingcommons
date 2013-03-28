require "#{ File.dirname(__FILE__)}/../test_helper"

class WatirTest < ActionController::IntegrationTest

  fixtures :people

  # ------------------------------------------------------------
  # Useful functions
  # ------------------------------------------------------------

  def setup
    @browser = Watir::Browser.new :chrome
  end

  def goto_home_page
    @browser.goto('http://test.host/')
  end

  def login_as_user(user_symbol)
    goto_home_page
    user = people(user_symbol)
    @browser.text_fields(:name => 'email_address').first.set user.email_address
    @browser.text_fields(:name => 'password').first.set user.password
    @browser.buttons(:text => 'Login').first.click

    assert_redirected_to :controller => :account, :action => :mypage
    follow_redirect!
    assert_response :success
  end

  def test_get_home_page
    goto_home_page
    login_as_user(:plain_user)
    assert_response :success
  end

end
