require "#{ File.dirname(__FILE__)}/../test_helper"

class GeneralStoriesTest < ActionController::IntegrationTest

  fixtures :people

  # ------------------------------------------------------------
  # Useful functions
  # ------------------------------------------------------------

  def login_as_user( user_symbol)
    user = people(user_symbol)
    post "/account/login_action", {  'email_address' => user.email_address,  'password' => user.password}

    assert_redirected_to :controller => "account", :action => "mypage"
    follow_redirect!
    assert_response :success
  end

  # ------------------------------------------------------------
  # Let's test!
  # ------------------------------------------------------------

  def test_get_home_page
    get '/'
    assert_redirected_to :controller => "account", :action => "login"
    login_as_user(:plain_user)
  end

end
