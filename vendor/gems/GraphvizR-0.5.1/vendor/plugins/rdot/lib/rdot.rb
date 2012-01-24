require 'graphviz_r'

class ActionController::Base
  def render_with_rdot(options = nil, deprecated_status = nil, &block) #:nodoc:
    if options == :rdot
      render_rdot deprecated_status, &block
    else
      render_without_rdot options, deprecated_status, &block
    end
  end
  #alias_method_chain :render, :rdot
  alias_method :render_without_rdot, :render
  alias_method :render, :render_with_rdot

  # render rdot. <tt>options</tt> hash can have <tt>:format</tt> and <tt>:disposition</tt>,
  # and their default values are 'png' and 'inline' respectively.
  #
  # rdot is directed in given block and the block can have zero or one argument.
  # If any argument is not given, only local variables can be refered in the block.
  # Otherwise, not only local variables but also instance one can be refered.
  #
  #   class RdotGenController < ApplicationController
  #     def index
  #       graph_size_directed_as_local_variable = '1.5, 2.5'
  #
  #       render :rdot do
  #         graph [:size => graph_size_directed_as_local_variable]
  #         node1 >> node2
  #       end
  #     end
  #   end
  #
  #   class RdotGenController < ApplicationController
  #     def index
  #       @graph_size_directed_as_instance_variable = '1.5, 2.5'
  #
  #       render :rdot do |gvr|
  #         gvr.graph [:size => @graph_size_directed_as_instance_variable]
  #         gvr.node1 >> gvr.node2
  #       end
  #     end
  #   end
  def render_rdot(options=nil, &block)
    options ||= {}
    format = options[:format] || 'png'
    options[:disposition] = 'attachment' unless options[:disposition] == 'inline'
    content_type = 
      case format
      when 'svg'
        'application/xml'
      when 'dot'
        'text/plain'
      else
        "image/#{format}"
      end
    gvr = GraphvizR.new 'generated'
    if block.arity == 1
      block.call gvr
    else
      copy_instance_variables block, gvr
      gvr.instance_eval &block
    end
    send_data gvr.data(format), :type => content_type ,:disposition => options[:disposition]
  end

private

  def copy_instance_variables(from_block, to_obj) #:nodoc:
    block_instance_variables = eval 'instance_variables', from_block.binding
    block_instance_variables.each do |name|
      to_obj.instance_variable_set name.to_sym, eval(name, from_block.binding)
    end
  end
end
