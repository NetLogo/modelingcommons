require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Person do
  before(:each) do
    @valid_attributes = {
      :first_name => 'First', :last_name => 'Last',
      :email_address => 'email@foo', :password => 'pw'}
  end

  it "should require a number of attributes in a valid person" do
    p = Person.new()
    p.should_not be_valid

    p = Person.new(:first_name => 'First', :last_name => 'Last')
    p.should_not be_valid

    p = Person.new(:first_name => 'First', :last_name => 'Last',
                   :email_address => 'email@foo')
    p.should_not be_valid
  end

  it "should not let more than one person have an e-mail address" do
    p1 = Person.create(@valid_attributes)
    p1.should be_valid

    p2 = Person.create(@valid_attributes)
    p2.should_not be_valid
  end

  it "should not be an administtrator by default" do
    p = Person.create(@valid_attributes)
    p.should_not be_administrator
  end

  it "should not let someone have a blank first name" do
    p = Person.create(@valid_attributes)
    p.should be_valid

    p.first_name = ''
    p.should_not be_valid
  end

  it "should not let someone have a blank last name" do
    p = Person.create(@valid_attributes)
    p.should be_valid

    p.last_name = ''
    p.should_not be_valid
  end

  it "should not let someone have a blank password" do
    p = Person.create(@valid_attributes)
    p.should be_valid

    p.password = ''
    p.should_not be_valid
  end

end
