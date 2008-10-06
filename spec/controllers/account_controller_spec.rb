require File.dirname(__FILE__) + '/../spec_helper'

describe AccountController, " create an account" do

  before do
    @params = {
      :email_address => 'foo@example.com',
      :first_name => 'Firstname',
      :last_name => 'Lastname',
      :password => 'password'
    }

    def do_post
      post :create, :new_person => @params
    end

    it "should let a new user create an account"
    it "should produce an error message if someone tries to register with an already-used e-mail address"
    it "should produce an error message if a user registers without providing first name, last name, e-mail address, and password"
  end
end

describe AccountController, "modify an account" do

  it "should let users change their e-mail address"
  it "should let users change their first name"
  it "should let users change their last name"
  it "should let users change their password"
end

describe AccountController, "log in" do
  it "should let an existing user log in"
  it "should not let people log in if their username is unknown"
  it "should not let people log in if the password is incorrect"
end

describe AccountController, "reset password" do
  it "should not let people reset their password unless they exist"
  it "should change the password"
  it "should send the new password to the user's e-mail address"
end

describe AccountController, "personal page" do
  it "should let me view my own personal page"
  it "should let me view someone else's personal page"
end
