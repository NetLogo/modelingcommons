require 'spec_helper'

describe "/foobars/index.html.erb" do
  include FoobarsHelper

  before(:each) do
    assigns[:foobars] = [
      stub_model(Foobar,
        :ab => "value for ab",
        :ef => 1
      ),
      stub_model(Foobar,
        :ab => "value for ab",
        :ef => 1
      )
    ]
  end

  it "renders a list of foobars" do
    render
    response.should have_tag("tr>td", "value for ab".to_s, 2)
    response.should have_tag("tr>td", 1.to_s, 2)
  end
end
