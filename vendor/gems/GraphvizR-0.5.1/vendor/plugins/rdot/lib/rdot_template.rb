# Process rdot template.
#
# == Rdot Template Example
#   class RdotGenController < ApplicationController
#     def index
#       @label1 = "<p_left> left|<p_center>center|<p_right> right"
#       @label2 = "left|center|right"
#     end
#   end
#   
#   # view/rdot_gen/index.rdot
#   graph [:size => '1.5, 2.5']
#   node [:shape => :record]
#   node1 [:label => @label1]
#   node2 [:label => @label2]
#   node1 >> node2
#   node1(:p_left) >> node2
#   node2 >> node1(:p_center)
#   (node2 >> node1(:p_right)) [:label => 'record']
#
# To know more about rdot, please see the documents for GraphvizR.
class RdotTemplate
  def initialize(view)
    @view = view
  end

  # render rdot template
  def render(template, local_assigns)
    params = @view.assigns['params']
    format = params['format'] || 'png'
    content_type = params['content_type'] || "image/#{format}"

    gvr = GraphvizR.new 'generated'
    @view.assigns.each do |name, value|
      gvr.instance_variable_set(('@' + name).to_sym, value)
    end
    gvr.instance_eval template
    @view.controller.__send__ :send_data, gvr.data(format), :type => content_type
  end
end

