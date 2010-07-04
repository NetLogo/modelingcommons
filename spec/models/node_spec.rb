require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

require 'factory_girl'
Dir.glob(File.join(File.dirname(__FILE__), '../../spec/factories/*.rb')).each { |f| require f}

def sample_netlogo_file(suffix='')
  File.open(RAILS_ROOT + "/features/upload_files/test#{suffix}.nlogo").readlines.join("\n")
end

describe Node do

  before(:each) do
    @valid_attributes = { }
  end

  after(:each) do
    NodeVersion.destroy_all
  end

  it "should not be valid without any attributes" do
    n = Node.new()
    n.should_not be_valid
  end

  it "should be valid with just a name" do
    n = Node.new(:name => "Foo model")
    n.should be_valid
  end

  it "should have default visibility setting" do
    n = Node.new(:name => "Foo model")
    n.should respond_to(:visibility)
    n.visibility_id.should == 1
  end

  it "should have default changeability setting" do
    n = Node.new(:name => "Foo model")
    n.should respond_to(:changeability)
    n.changeability_id.should == 1
  end

  it "should have no versions by default" do
    n = Node.new(:name => "Foo model")
    n.node_versions.should be_empty
    n.current_version.should be_nil
  end

  it "should be able to take multiple versions" do
    n = Node.create(:name => "Foo model")

    person = Factory.create(:person)

    3.times do |number|
      node_version = Factory.create(:node_version,
                                    :node_id => n.id,
                                    :person_id => person.id,
                                    :description => "Description of the node version",
                                    :contents => sample_netlogo_file)
      n.node_versions.length.should == number + 1
    end
  end

  it "should report the people involved with the model" do
    n = Node.create(:name => "Foo model")

    person = Factory.create(:person)
    node_version = Factory.create(:node_version,
                                  :node_id => n.id,
                                  :person_id => person.id,
                                  :description => "Description of the node version",
                                  :contents => sample_netlogo_file)

    person2 = Factory.create(:person)
    node_version2 = Factory.create(:node_version,
                                   :node_id => n.id,
                                   :person_id => person2.id,
                                   :description => "Description of the node version",
                                   :contents => sample_netlogo_file)

    n.people.length.should == 2
    n.most_recent_author.should == person2

    n.author?(person).should be_true
    n.author?(person2).should be_true

    person3 = Factory.create(:person)
    n.author?(person3).should_not be_true
  end

  it "should give me the contents of the latest version" do
    n = Node.create(:name => "Foo model")

    person = Factory.create(:person)
    node_version = Factory.create(:node_version,
                                  :node_id => n.id,
                                  :person_id => person.id,
                                  :description => "Description of the node version",
                                  :contents => sample_netlogo_file)
    n.contents.should == sample_netlogo_file
  end

  it "should give me the NetLogo version of the model" do
    n = Node.create(:name => "Foo model")

    person = Factory.create(:person)
    node_version = Factory.create(:node_version,
                                  :node_id => n.id,
                                  :person_id => person.id,
                                  :description => "Description of the node version",
                                  :contents => sample_netlogo_file)
    n.netlogo_version.should == '4.1'
    n.netlogo_version_for_applet.should == '4.1'
    n.applet_class.should == "org.nlogo.lite.Applet"
  end

end
