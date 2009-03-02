require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Group do
  before(:each) do
    @valid_attributes = {
      :name => 'mygroup'
    }
  end

  it "should require a number of attributes in a valid group" do
    g = Group.new()
    g.should_not be_valid

    g = Group.new(@valid_attributes)
    g.should be_valid
  end

  it "should not let a group have a blank name" do
    g = Group.create(@valid_attributes)
    g.should be_valid

    g.name = ''
    g.should_not be_valid
  end

  it "should not let two groups have the same name" do
    g1 = Group.create(@valid_attributes)
    g1.should be_valid

    g2 = Group.create(@valid_attributes)
    g2.should_not be_valid
  end



end
