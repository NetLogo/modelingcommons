require File.dirname(__FILE__) + '/../spec_helper'

describe Posting do

  it "should be associated with a model"
  it "should be written by a valid person"
  it "should have a title"
  it "should have some content"

  it "should not have a parent, at least by default"
  it "should not be a question, at least by default"

  it "should have a parent, if this is a reply message"
  it "should be a question, if the user indicates as such"

end
