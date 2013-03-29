require 'spec_helper'

describe Person do
  before(:each) do
    @valid_attributes = {
      :email_address => "foo@bar.com",
      :password => 'password',
      :first_name => 'firstname',
      :last_name => 'lastname',
      :administrator => false,
      :registration_consent => true
    }
  end

  it "should create a new instance given valid attributes" do
    Person.create!(@valid_attributes)
  end
end
