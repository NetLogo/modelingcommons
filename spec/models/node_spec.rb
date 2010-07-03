require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Node do

  before(:each) do
    @valid_attributes = { }
  end

  it "should not be valid without any attributes" do
    n = Node.new()
    n.should_not be_valid
  end

  it "should not be valid with just a name" do
    n = Node.new(:name => "Foo model")
    n.should_not be_valid
  end

end
