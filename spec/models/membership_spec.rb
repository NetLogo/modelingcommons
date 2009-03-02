require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Membership do
  before(:each) do
    @person = Person.create(:first_name => 'First', :last_name => 'Last',
                            :email_address => 'email@foo', :password => 'pw')

    @group = Group.create(:name => 'agroup')

    @valid_attributes = {
    }
  end

  it "should be possible for someone to join a group" do
  end

  it "should be possible for someone to leave a group" do
  end

  it "should not be possible to join a group twice" do
  end

end
