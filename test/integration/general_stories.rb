require "#{ File.dirname(__FILE__)}/../test_helper"

class GeneralStoriesTest < ActionController::IntegrationTest

  fixtures :people

  # ------------------------------------------------------------
  # Useful functions
  # ------------------------------------------------------------

  def login_as_user( user_symbol)
    user = people(user_symbol)
    post "/account/login_action", {  'email_address' => user.email_address,  'password' => user.password}

    assert_redirected_to :controller => :account, :action => :mypage
    follow_redirect!
    assert_response :success
  end

  # ------------------------------------------------------------
  # Let's test!
  # ------------------------------------------------------------

  def test_get_home_page
    get '/'
    assert_redirected_to :controller => :account, :action => :login
    follow_redirect!
    assert_response :success

    login_as_user(:plain_user)
    get '/'
    assert_response :success
  end

  # Account controller

  def test_get_home_page
    get '/'
    assert_redirected_to :controller => :account, :action => :login
    follow_redirect!
    assert_response :success

    login_as_user(:plain_user)
    get '/'
    assert_response :success
  end

  def test_account_methods_without_being_logged_in_first
    controller_actions = %w(edit update mypage reset_password update_password_action models)
    controller_actions.each do |url|
      get '/account' + url
      assert_redirected_to :controller => :account, :action => :login
      follow_redirect!
      assert_response :success
    end
  end

  def test_controller_account_action_new
    login_as_user(:plain_user)
    get '/account/new'
    assert_response :success
  end

  def test_controller_account_action_create
    login_as_user(:plain_user)
    get '/account/create', { }, { :referer => '/account' }
    assert_redirected_to :controller => :account, :action => :index
    follow_redirect!
    assert_response :success
  end

  def test_controller_account_action_edit
    login_as_user(:plain_user)
    get '/account/edit'
    assert_response :success
  end

  def test_controller_account_action_update
    login_as_user(:plain_user)
    get '/account/update', { }, { :referer => '/account'}
    assert_redirected_to :controller => :account, :action => :index
    follow_redirect!
    assert_response :success
  end

  def test_controller_account_action_login
    login_as_user(:plain_user)
    get '/account/login'
    assert_response :success
  end

  def test_controller_account_action_login_action
    login_as_user(:plain_user)
    get '/account/login_action', { }, { :referer => '/account/login'}
    assert_redirected_to :controller => :account, :action => :login
    follow_redirect!
    assert_response :success
  end

  def test_controller_account_action_logout
    login_as_user(:plain_user)
    get '/account/logout'
    assert_redirected_to :controller => :account, :action => :login
    follow_redirect!
    assert_response :success
  end

  def test_controller_account_action_mypage
    login_as_user(:plain_user)
    get '/account/mypage'
    assert_response :success
  end

  def test_controller_account_action_reset_password
    login_as_user(:plain_user)
    get '/account/reset_password'
    assert_redirected_to :controller => :account, :action => :index
    follow_redirect!
    assert_response :success
  end

  def test_controller_account_action_update_password_action
    login_as_user(:plain_user)
    get '/account/update_password_action', { }, { :referer => '/account' }
    assert_redirected_to :controller => :account, :action => :index
    follow_redirect!
    assert_response :success
  end

  def test_controller_account_action_send_password_action
    login_as_user(:plain_user)
    get '/account/send_password_action', { }, { :referer => '/'}
    assert_redirected_to :controller => :account, :action => :mypage
    follow_redirect!
    assert_response :success
  end

  def test_controller_account_action_follow
    login_as_user(:plain_user)
    get '/account/follow', { }, { :referer => '/account/login' }
    assert_redirected_to :controller => :account, :action => :login
    follow_redirect!
    assert_response :success
  end

  def test_controller_account_action_models
    login_as_user(:plain_user)
    get '/account/models'
    assert_response :success
  end


  # Browse controller
  def test_browse_methods_without_being_logged_in_first
    controller_actions = %w(index list_models list_models_group one_node revert_model search_action news compare_versions set_permissions whats_new as_tree view_random_model )
    controller_actions.each do |url|
      RAILS_DEFAULT_LOGGER.debug "[test_browse_methods_without_being_logged_in_first] URL = '#{url}'"
      get '/browse/' + url
      assert_redirected_to :controller => :account, :action => :login
      follow_redirect!
      assert_response :success
    end
  end

  def test_browse_tab_methods_without_being_logged_in_first
    controller_actions = %w(preview info applet download discuss tags related files procedures gui upload permissions history)
    controller_actions.each do |url|
      RAILS_DEFAULT_LOGGER.debug "[test_browse_tab_methods_without_being_logged_in_first] URL = '#{url}'"
      get '/browse/browse_' + url + 'tab'
      assert_redirected_to :controller => :account, :action => :login
      follow_redirect!
      assert_response :success
    end
  end

  def test_controller_account_action_models
    login_as_user(:plain_user)
    get '/browse/one_model/1'
    assert_response :success
  end


end
