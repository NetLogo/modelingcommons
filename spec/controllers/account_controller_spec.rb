require 'spec_helper'

describe AccountController do

  def mock_account(stubs={})
    @mock_account ||= mock_model(Account, stubs)
  end

  describe "login" do 
    it "should be possible to get the login page" do 
      get :login
      response.should render_template('login')
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
