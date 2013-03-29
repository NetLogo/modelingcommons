require 'spec_helper'

describe "/foobars/edit.html.erb" do
  include FoobarsHelper

  before(:each) do
    assigns[:foobar] = @foobar = stub_model(Foobar,
      :new_record? => false,
      :ab => "value for ab",
      :ef => 1
    )
  end

  it "renders the edit foobar form" do
    render

    response.should have_tag("form[action=#{foobar_path(@foobar)}][method=post]") do
      with_tag('input#foobar_ab[name=?]', "foobar[ab]")
      with_tag('input#foobar_ef[name=?]', "foobar[ef]")
    end
  end
end
