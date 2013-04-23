require 'spec_helper'

describe Node do

  def mock_collaborator_type(stubs={})
    @mock_collaborator_type ||= mock_model(CollaboratorType, stubs)
  end

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
      n = Node.new(@valid_attributes)
      expect(n).to be_valid
    end

    it "should not create a new instance if name is blank" do
      @valid_attributes.delete(:name)
      n = Node.new(@valid_attributes)
      expect(n).to_not be_valid
    end
  end

  context "new, empty nodes" do 
    it "should have no versions to start with" do
      n = Node.new(@valid_attributes)
      expect(n.versions).to be_empty
    end

    it "should have no authors to start with" do
      n = Node.new(@valid_attributes)
      expect(n.authors).to be_empty
    end
  end

  context "adding node versions" do 

    it "should register a version after we have saved it" do

      CollaboratorType.stub(:find_by_name).and_return(mock_collaborator_type)
      p = Person.create(:email_address => "foo@bar.com",
                        :password => 'password',
                        :first_name => 'firstname',
                        :last_name => 'lastname',
                        :administrator => false,
                        :registration_consent => true)
      expect(p).to be_valid

      n = Node.create(@valid_attributes)
      expect(n).to be_valid
    end

  end

end

