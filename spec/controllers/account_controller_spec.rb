require 'spec_helper'

describe AccountController do

  def mock_person(stubs={})
    @mock_person ||= mock_model(Person, stubs)
  end

  let(:sample_person) { mock_person(:salt => 'abc',
                             :password => 'password',
                             :first_name => 'Reuven',
                             :last_name => 'Lerner') }

  describe "new" do 
    it "should be possible to get a registration form" do 
      get :new
      expect(response).to render_template("account/new")
    end

  end

  describe "login" do 
    it "should be possible to get the login page" do 
      get :login
      expect(response).to render_template('login')
    end
  end

  describe "login_action" do 

    let(:person) { mock_person(:salt => 'abc',
                               :password => 'password',
                               :first_name => 'Reuven',
                               :last_name => 'Lerner') }

    before(:each) do 
      @request.env["HTTP_REFERER"] = '/account/login'
    end

    it "should not be possible to login with a blank username" do 

      post :login_action, :email_address => '', :password => 'password'

      expect(response).to redirect_to(:controller => :account, :action => :login)
      expect(flash[:notice]).to eq("You must provide an e-mail address and password in order to log in.")
    end

    it "should not be possible to login with an unknown username" do 
      post :login_action, :email_address => 'foo@barbaz.com', :password => 'password'
      expect(response).to redirect_to(:controller => :account, :action => :login)
      expect(flash[:notice]).to eq("Sorry, but no user exists with that e-mail address and password.  Please try again.")
    end


    it "should not be possible to login with a blank password" do 
      post :login_action, :email_address => 'reuven@lerner.co.il', :password => ''
      expect(response).to redirect_to(:controller => :account, :action => :login)
      expect(flash[:notice]).to eq("You must provide an e-mail address and password in order to log in.")
    end

    it "should not be possible to login with a bad password" do 
      Person.stub(:find_by_email_address).and_return(mock_person)
      post :login_action, :email_address => 'reuven@lerner.co.il', :password => 'password'
      expect(response).to redirect_to(:controller => :account, :action => :login)
      expect(flash[:notice]).to eq("Sorry, but no user exists with that e-mail address and password.  Please try again.")
    end

    it "should be possible to login with a good password" do 
      Person.stub(:find_by_email_address).and_return(sample_person)
      Person.stub(:encrypted_password).and_return('password')
      post :login_action, :email_address => 'reuven@lerner.co.il', :password => 'password'
      expect(response).to redirect_to(:controller => :account, :action => :mypage)
      expect(flash[:notice]).to eq("Welcome back to the Commons, Reuven!")
    end
  end
  
  describe "mypage" do 

    before(:each) do
      Person.stub(:find_by_id).and_return(sample_person)
      sample_person.stub(:tags).and_return([])
      sample_person.stub(:tagged_nodes).and_return([])
      sample_person.stub(:models).and_return([])
    end

    it "going to personal page without being logged in sends to login" do 
      get :mypage
      expect(response).to redirect_to(:controller => :account, :action => :login)
    end

    it "going to personal page while logged in greets person" do

    end


  end

  describe "create" do 

    before(:each) do 
      @request.env["HTTP_REFERER"] = '/account/new'
    end

    it "should not create a new person without required fields" do 
      people_before = Person.count
      post :create
      expect(Person.count).to eq(people_before)
    end
  end

  describe "groups" do 
    it "should not give an error when an anonymous user visits the 'group' page" do 
      
    end
  end

end
