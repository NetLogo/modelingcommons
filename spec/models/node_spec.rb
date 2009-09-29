require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Node do
  before(:each) do
    @valid_attributes = {
      :first_name => 'First', :last_name => 'Last',
      :email_address => 'email@foo.com', :password => 'pw'}
  end

  it "should have a name" do
    p = Person.new()
    p.should_not be_valid

    p = Person.new(:first_name => 'First', :last_name => 'Last')
    p.should_not be_valid

    p = Person.new(:first_name => 'First', :last_name => 'Last',
                   :email_address => 'email@foo')
    p.should_not be_valid
  end

end
