require File.dirname(__FILE__) + '/../spec_helper'

describe Person, "when created" do

  before(:each) do
    @person = Person.new
  end

  def populate_person_object(person)
    person.first_name = 'Reuven'
    person.last_name = 'Lerner'
    person.password = 'password'
    person.email_address = 'foo@bar.com'
  end

  it "should not be valid by default" do
    @person.should_not be_valid
  end

  it "should be valid after we have given it some data" do
    populate_person_object(@person)
    @person.should be_valid
  end

  it "should not make people administrators by default" do
    populate_person_object(@person)
    @person.should_not be_administrator
  end

  it "should not allow more than one user with the same e-mail address" do
    populate_person_object(@person)
    @person.save!

    @other = Person.new
    @other.should_not === @person

    populate_person_object(@other)
    @other.should_not be_valid
  end

  it "should have created no models by default" do
    @person.nlmodels.length.should == 0
  end

  it "should have authored no model versions by default" do
    @person.nlmodel_versions.length.should == 0
  end

  it "should have authored no postings by default" do
    @person.postings.length.should == 0
  end

  it "should have authored no news items by default" do
    @person.news_items.length.should == 0
  end

  it "should have logged no actions by default" do
    @person.logged_actions.length.should == 0
  end

  it "should have created no tags by default" do
    @person.tags.length.should == 0
  end

  it "should have tagged no models by default" do
    @person.tagged_models.length.should == 0
  end

  it "should have submitted no nlmodel documents by default" do
    @person.nlmodel_documents.length.should == 0
  end

  it "should return the combination of first and last names when .fullname is invoked" do
    populate_person_object(@person)
    @person.fullname == "Reuven Lerner"
  end

end
