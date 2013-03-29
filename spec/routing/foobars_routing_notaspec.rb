require 'spec_helper'

describe FoobarsController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "/foobars" }.should route_to(:controller => "foobars", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/foobars/new" }.should route_to(:controller => "foobars", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/foobars/1" }.should route_to(:controller => "foobars", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/foobars/1/edit" }.should route_to(:controller => "foobars", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/foobars" }.should route_to(:controller => "foobars", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "/foobars/1" }.should route_to(:controller => "foobars", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "/foobars/1" }.should route_to(:controller => "foobars", :action => "destroy", :id => "1") 
    end
  end
end
