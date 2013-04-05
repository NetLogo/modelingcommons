require 'spec_helper'


describe "home page" do
  before(:all) do
    @browser = Watir::Browser.new :chrome
    @browser.goto("http://cukes.info/")
  end

  after(:all) do
    @browser.kill! rescue nil
  end

  describe "that we have hit a valid URL" do
    it "will tell us local info" do
      get :index
    end

    it "should not return an invalid error message" do
      @browser.text.should_not include('The requested URL could not be retrieved')
    end
  end

  describe "the contents of the cukes page" do # the describe() is an example group
    it "should include aidy's name" do # the it() represents the detail that will be expressed in the code within the block
      @browser.text.should include('Aidy Lewis')
    end

    it "should not include the great Nietchzche's name" do
      @browser.text.should_not include('Frederick Nietchzche')
    end
  end
end

# describe "home page" do
#   it "displays the user's username after successful login" do

#     user = Person.create!(:email_address => "reuven@lerner.co.il",
#                           :first_name => 'Reuven',
#                           :last_name => 'Lerner',
#                           :registration_consent => true,
#                           :password => "secret")

#     visit "/account/login"
#     fill_in "email_address", :with => "reuven@lerner.co.il"
#     fill_in "password", :with => "secret"
#     click_button "Login"

#     STDERR.puts page.inspect
#     page.should have_content("Your personal page")
#     page.should have_content("Reuven Lerner")
#   end
# end
