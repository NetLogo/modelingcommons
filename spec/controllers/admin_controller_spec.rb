require File.dirname(__FILE__) + '/../spec_helper'

describe AdminController, " administrative tools" do

  it "should list all of the people successfully" do
    get "/admin/index"
    response.should have_tag("a")
  end

  it "should not be visible to non-administrators"
  it "should display an image"
  it "should let an administrator list all people in the system"
  it "should let an administrator list all of a person's logged actions"
  it "should let an administrator list all logged actions"
  it "should let an administrator create a news posting"
end

