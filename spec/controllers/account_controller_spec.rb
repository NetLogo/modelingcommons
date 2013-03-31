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

    before(:each) do 
      @request.env["HTTP_REFERER"] = '/account/login'
    end

    it "should not be possible to login with a blank username" do 

      post :login_action, :foobar => {
        :email_address => '',
        :password => 'password'
      }

      response.should redirect_to(:controller => :account, :action => :login)
      flash[:notice].should == "You must provide an e-mail address and password in order to log in."
      @person.should be_nil
    end

    it "should not be possible to login with a blank password" do 

      post :login_action, :foobar => {
        :email_address => 'reuven@lerner.co.il',
        :password => ''
      }

      response.should redirect_to(:controller => :account, :action => :login)
      flash[:notice].should == "You must provide an e-mail address and password in order to log in."
      @person.should be_nil
    end

    it "should not be possible to login with a bad password" do 

      Person.stub(:find_by_email_address).and_return(mock_person(:salt => 'abc', :password => 'aaa'))

      post :login_action, :email_address => 'reuven@lerner.co.il', :password => 'password'

      response.should redirect_to(:controller => :account, :action => :login)
      flash[:notice].should == "Sorry, but no user exists with that e-mail address and password.  Please try again."
      @person.should be_nil
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
