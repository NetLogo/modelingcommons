require 'spec_helper'

describe Node do
  before(:each) do
    @valid_attributes = {
      :name => "mynode",
      :parent_id => nil,
      :visibility_id => 1,
      :changeability_id => 1,
      :group_id => nil
    }
  end

  context "basic creation" do 

    it "should create a new instance given valid attributes" do
      Node.create!(@valid_attributes)
    end

    it "should not create a new instance if name is blank" do
      @valid_attributes.delete(:name)
      n = Node.new(@valid_attributes)
      n.should_not be_valid
    end
  end

  context "new, empty nodes" do 
    it "should have no versions to start with" do
      n = Node.new(@valid_attributes)
      n.node_versions.should be_empty
    end

    it "should have no authors to start with" do
      n = Node.new(@valid_attributes)
      n.authors.should be_empty
    end
  end

  context "adding node versions" do 

    it "should register a version after we have saved it" do

      p = Person.create(:email_address => "foo@bar.com",
                        :password => 'password',
                        :first_name => 'firstname',
                        :last_name => 'lastname',
                        :administrator => false,
                        :registration_consent => true)
      p.should be_valid

      n = Node.create(@valid_attributes)
      n.should be_valid

      number_of_versions = n.node_versions.size

      nv = NodeVersion.create(:node_id => n.id,
                              :person_id => p.id, 
                              :description => 'a description',
                              :contents => File.read(Rails.root + 'spec/fixtures/sample.nlogo'))
      nv.should be_valid
      n.node_versions.size.should == (number_of_versions + 1)
      n.authors.first.should == p
    end

  end

end

