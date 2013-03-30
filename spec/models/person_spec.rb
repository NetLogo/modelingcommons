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

  %w(email_address password first_name last_name registration_consent).each do |field|
    it "should not create a new instance if '#{field}' is unchecked" do
      @valid_attributes.delete(field.to_sym)
      p = Person.new(@valid_attributes)
      p.should_not be_valid
    end
  end

end
