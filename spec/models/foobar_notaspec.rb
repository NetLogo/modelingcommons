require 'spec_helper'

describe Foobar do
  before(:each) do
    @valid_attributes = {
      :ab => "value for ab",
      :cd => Time.now,
      :ef => 1
    }
  end

  it "should create a new instance given valid attributes" do
    Foobar.create!(@valid_attributes)
  end
end
