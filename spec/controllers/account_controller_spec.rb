require 'spec_helper'

describe AccountController do

  def mock_person(stubs={})
    @mock_person ||= mock_model(Person, stubs)
  end

  describe "login" do 
    it "should be possible to get the login page" do 
      get :login
      response.should render_template('login')
    end
  end

  describe "login_action" do 
    it "should not be possible to login with a blank username" do 

      get :login
      post :login_action, :foobar => {
        :email_address => '',
        :password => 'password'
      }

      response.should redirect_to(:controller => :account, :action => :login)
    end

    it "should not be possible to login with a blank password" do 

      get :login
      post :login_action, :foobar => {
        :email_address => 'reuven@lerner.co.il',
        :password => ''
      }

      response.should redirect_to(:controller => :account, :action => :login)
    end
  end

  describe "mypage" 
  describe "new" 
  describe "create" 
  describe "edit" 
  describe "tags" 
  describe "update" 
  describe "login_action" 
  describe "logout" 
  describe "follow" 
  describe "models" 
  describe "groups" 
  describe "find_people" 
  describe "get_feed" 
  describe "list_groups" 
  describe "download" 

end
