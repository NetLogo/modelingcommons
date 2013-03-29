require 'spec_helper'

describe "/foobars/show.html.erb" do
  include FoobarsHelper
  before(:each) do
    assigns[:foobar] = @foobar = stub_model(Foobar,
      :ab => "value for ab",
      :ef => 1
    )
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(/value\ for\ ab/)
    response.should have_text(/1/)
  end
end
