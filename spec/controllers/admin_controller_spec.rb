require File.dirname(__FILE__) + '/../spec_helper'

describe AdminController, " administrative tools" do
  it "should not be visible to non-administrators"
  it "should let an administrator list all people in the system"
  it "should let an administrator list all of a person's logged actions"
  it "should let an administrator list all logged actions"
  it "should let an administrator create a news posting"
end

