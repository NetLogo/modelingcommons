require File.dirname(__FILE__) + '/test_helper'
require 'test/unit'

class RdotGenController < ActionController::Base
  def call_with_gvr
    local_var = 'node1_label'

    render :rdot do |gvr|
      gvr.graph [:size => '1.5, 2.5']
      gvr.node1 [:label => local_var]
      gvr.node2 [:label => 'node2_label']
      gvr.node1 >> gvr.node2
    end
  end

  def call_with_nothing
    local_var = 'node1_label'
    @instance_var = 'node2_label'

    render :rdot do
      graph [:size => '1.5, 2.5']
      node1 [:label => local_var]
      node2 [:label => @instance_var]
      node1 >> node2
    end
  end
end

class RdotTest < Test::Unit::TestCase
  def setup
    @controller = RdotGenController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end

  def test_call_with_gvr
    get_and_assert :call_with_gvr
  end
  
  def test_call_with_nothing
    get_and_assert :call_with_nothing
  end

  def get_and_assert(action)
    get action, :format => 'dot'
    assert_response :success
    assert <<-end_of_string, @response.body
generated {
  graph [];
  node1 [label = 'node1_label'];
  node2 [label = 'node2_label'];
  node1 -> node2;
}
    end_of_string
  end
end
