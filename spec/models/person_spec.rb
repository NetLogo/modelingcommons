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

  it "should not create a new instance if checkbox is unchecked" do
    @valid_attributes.delete(:registration_consent)
    Person.should_not create!(@valid_attributes)
  end

end
