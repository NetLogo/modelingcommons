require File.dirname(__FILE__) + '/../spec_helper'

describe Tag do

  it "should have a name"
  it "should have a name that has not yet been taken"
  it "should be created by a person"
  it "should have no models associated with it, at least by default"

  it "should be associated with one or more models via a tagged_model object"
  it "should be associated with one or more people via a tagged_model object"

end
