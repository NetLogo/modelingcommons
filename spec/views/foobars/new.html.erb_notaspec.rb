require 'spec_helper'

describe "/foobars/new.html.erb" do
  include FoobarsHelper

  before(:each) do
    assigns[:foobar] = stub_model(Foobar,
      :new_record? => true,
      :ab => "value for ab",
      :ef => 1
    )
  end

  it "renders new foobar form" do
    render

    response.should have_tag("form[action=?][method=post]", foobars_path) do
      with_tag("input#foobar_ab[name=?]", "foobar[ab]")
      with_tag("input#foobar_ef[name=?]", "foobar[ef]")
    end
  end
end
