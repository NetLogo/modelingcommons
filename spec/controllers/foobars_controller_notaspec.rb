require 'spec_helper'

describe FoobarsController do

  def mock_foobar(stubs={})
    @mock_foobar ||= mock_model(Foobar, stubs)
  end

  describe "GET index" do
    it "assigns all foobars as @foobars" do
      Foobar.stub(:find).with(:all).and_return([mock_foobar])
      get :index
      assigns[:foobars].should == [mock_foobar]
    end
  end

  describe "GET show" do
    it "assigns the requested foobar as @foobar" do
      Foobar.stub(:find).with("37").and_return(mock_foobar)
      get :show, :id => "37"
      assigns[:foobar].should equal(mock_foobar)
    end
  end

  describe "GET new" do
    it "assigns a new foobar as @foobar" do
      Foobar.stub(:new).and_return(mock_foobar)
      get :new
      assigns[:foobar].should equal(mock_foobar)
    end
  end

  describe "GET edit" do
    it "assigns the requested foobar as @foobar" do
      Foobar.stub(:find).with("37").and_return(mock_foobar)
      get :edit, :id => "37"
      assigns[:foobar].should equal(mock_foobar)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created foobar as @foobar" do
        Foobar.stub(:new).with({'these' => 'params'}).and_return(mock_foobar(:save => true))
        post :create, :foobar => {:these => 'params'}
        assigns[:foobar].should equal(mock_foobar)
      end

      it "redirects to the created foobar" do
        Foobar.stub(:new).and_return(mock_foobar(:save => true))
        post :create, :foobar => {}
        response.should redirect_to(foobar_url(mock_foobar))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved foobar as @foobar" do
        Foobar.stub(:new).with({'these' => 'params'}).and_return(mock_foobar(:save => false))
        post :create, :foobar => {:these => 'params'}
        assigns[:foobar].should equal(mock_foobar)
      end

      it "re-renders the 'new' template" do
        Foobar.stub(:new).and_return(mock_foobar(:save => false))
        post :create, :foobar => {}
        response.should render_template('new')
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested foobar" do
        Foobar.should_receive(:find).with("37").and_return(mock_foobar)
        mock_foobar.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :foobar => {:these => 'params'}
      end

      it "assigns the requested foobar as @foobar" do
        Foobar.stub(:find).and_return(mock_foobar(:update_attributes => true))
        put :update, :id => "1"
        assigns[:foobar].should equal(mock_foobar)
      end

      it "redirects to the foobar" do
        Foobar.stub(:find).and_return(mock_foobar(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(foobar_url(mock_foobar))
      end
    end

    describe "with invalid params" do
      it "updates the requested foobar" do
        Foobar.should_receive(:find).with("37").and_return(mock_foobar)
        mock_foobar.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :foobar => {:these => 'params'}
      end

      it "assigns the foobar as @foobar" do
        Foobar.stub(:find).and_return(mock_foobar(:update_attributes => false))
        put :update, :id => "1"
        assigns[:foobar].should equal(mock_foobar)
      end

      it "re-renders the 'edit' template" do
        Foobar.stub(:find).and_return(mock_foobar(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested foobar" do
      Foobar.should_receive(:find).with("37").and_return(mock_foobar)
      mock_foobar.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the foobars list" do
      Foobar.stub(:find).and_return(mock_foobar(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(foobars_url)
    end
  end

end
