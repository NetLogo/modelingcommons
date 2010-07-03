# Controller to create graphviz graphics

class GraphController < ApplicationController

  before_filter :get_model_from_id_param

  def graphviz
    logger.warn "model = '#{@model.inspect}'"
    stem = "graphviz_#{Time.now.to_i}"
    format = 'png'
    filename = "/tmp/#{stem}.#{format}"

    gvr = GraphvizR.new stem

    # Gather the nodes we will include in our graph
    nodes_to_graph = [@model]

    nodes_to_graph.each do |node|
      if node.parent
        nodes_to_graph << node.parent unless nodes_to_graph.member?(node.parent)
      end

      node.children.sort_by { |node| node.id}.each do |child|
        nodes_to_graph << child unless nodes_to_graph.member?(child)
      end
    end

    # Iterate over the nodes, and graph them
    already_graphed = Hash.new({ })

    nodes_to_graph.sort_by { |node| node.id}.each do |node|

      # First, draw the current model
      if node == @model
        gvr.send(node.id.to_s.to_sym, [:style => 'filled', :color => "#ff0000", :label => "#{node.name}\n(You are here)"])
      else
        gvr.send(node.id.to_s.to_sym, [:label => node.name])
      end

      if node.parent
        gvr[node.parent.id] >> gvr[node.id] unless already_graphed[node.parent.id].has_key?(node.id)
        already_graphed[node.parent.id][node.id] = 1
      end

      node.children.each do |child|
        gvr[node.id] >> gvr[child.id] unless already_graphed[node.id].has_key?(child.id)
        already_graphed[node.id][child.id] = 1
      end
    end

    gvr.output(filename=filename)
    send_file filename, :type => 'image/png', :disposition => 'inline'
  end

end
