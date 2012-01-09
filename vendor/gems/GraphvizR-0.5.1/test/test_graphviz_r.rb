require 'test/unit'
require 'graphviz_r'

class TestGraphvizR < Test::Unit::TestCase
  def test_access_as_hash
    gvr = GraphvizR.new 'sample'
    (gvr['alpha'] >> gvr['beta']) [:label => "label1"]

    assert_equal <<-end_of_string, gvr.to_dot
digraph sample {
  alpha -> beta [label = "label1"];
}
    end_of_string
  end

  def test_no_node
    gvr = GraphvizR.new 'sample'

    assert_equal <<-end_of_string, gvr.to_dot
digraph sample {
}
    end_of_string
  end

  def test_just_node
    gvr = GraphvizR.new 'sample'
    gvr.alpha

    assert_equal <<-end_of_string, gvr.to_dot
digraph sample {
  alpha;
}
    end_of_string
  end

  def test_graph_setting
    gvr = GraphvizR.new 'sample'
    gvr.graph [:label => 'example', :size => '1.5, 2.5']

    assert_equal <<-end_of_string, gvr.to_dot
digraph sample {
  graph [label = "example", size = "1.5, 2.5"];
}
    end_of_string
  end

  def test_graph_setting_without_blank
    gvr = GraphvizR.new 'sample'
    gvr.graph[:label => 'example', :size => '1.5, 2.5']

    assert_equal <<-end_of_string, gvr.to_dot
digraph sample {
  graph [label = "example", size = "1.5, 2.5"];
}
    end_of_string
  end

  def test_edge
    gvr = GraphvizR.new 'sample'
    gvr.alpha >> gvr.beta

    assert_equal <<-end_of_string, gvr.to_dot
digraph sample {
  alpha -> beta;
}
    end_of_string
  end

  def test_edge_with_attributes
    gvr = GraphvizR.new 'sample'
    (gvr.alpha >> gvr.beta) [:label => 'label1']

    assert_equal <<-end_of_string, gvr.to_dot
digraph sample {
  alpha -> beta [label = "label1"];
}
    end_of_string
  end

  def test_edge_with_attributes_without_blank
    gvr = GraphvizR.new 'sample'
    (gvr.alpha >> gvr.beta)[:label => 'label1']

    assert_equal <<-end_of_string, gvr.to_dot
digraph sample {
  alpha -> beta [label = "label1"];
}
    end_of_string
  end

  def test_record_edge
    gvr = GraphvizR.new 'sample'
    gvr.node1(:p_left) >> gvr.node2
    gvr.node2 >> gvr.node1(:p_center)

    assert_equal <<-end_of_string, gvr.to_dot
digraph sample {
  node1:p_left -> node2;
  node2 -> node1:p_center;
}
    end_of_string
  end

  def test_record_edge_with_attributes
    gvr = GraphvizR.new 'sample'
    (gvr.node2 >> gvr.node1(:p_right)) [:label => 'record']

    assert_equal <<-end_of_string, gvr.to_dot
digraph sample {
  node2 -> node1:p_right [label = "record"];
}
    end_of_string
  end

  def test_simple_graph
    gvr = GraphvizR.new 'sample'
    gvr.graph [:label => 'example', :size => '1.5, 2.5'] 
    gvr.beta [:shape => :box]                            
    gvr.alpha >> gvr.beta
    (gvr.alpha >> gvr.gamma) [:label => 'label1']
    (gvr.beta >> gvr.delta) [:label => 'label2']
    gvr.delta >> gvr[:size]

    assert_equal <<-end_of_string, gvr.to_dot
digraph sample {
  graph [label = "example", size = "1.5, 2.5"];
  beta [shape = box];
  alpha -> beta;
  alpha -> gamma [label = "label1"];
  beta -> delta [label = "label2"];
  delta -> size;
}
    end_of_string
  end

  def test_define_subgraph
    gvr = GraphvizR.new 'sample'
    gvr.cluster0 do |c0|
      c0.graph [:color => :blue, :label => 'area 0', :style => :bold]
      c0.a >> c0.b
    end
    
    assert_equal <<-end_of_string, gvr.to_dot
digraph sample {
  subgraph cluster0 {
    graph [color = blue, label = "area 0", style = bold];
    a -> b;
  }
}
    end_of_string
  end

  def test_subgraph
    gvr = GraphvizR.new 'sample'
    gvr.cluster0 do |c0|
      c0.graph [:color => :blue, :label => 'area 0', :style => :bold]
      c0.a >> c0.b
      c0.a >> c0.c
    end
    gvr.cluster1 do |c1|
      c1.graph [:fillcolor => '#cc9966', :label => 'area 1', :style => :filled]
      c1.d >> c1.e
      c1.d >> c1.f
    end
    (gvr.a >> gvr.f) [:lhead => :cluster1, :ltail => :cluster0]
    gvr.b >> gvr.d
    (gvr.c >> gvr.d) [:ltail => :cluster0]
    (gvr.c >> gvr.f) [:lhead => :cluster1]

    assert_equal <<-end_of_string, gvr.to_dot
digraph sample {
  subgraph cluster0 {
    graph [color = blue, label = "area 0", style = bold];
    a -> b;
    a -> c;
  }
  subgraph cluster1 {
    graph [fillcolor = "#cc9966", label = "area 1", style = filled];
    d -> e;
    d -> f;
  }
  a -> f [lhead = cluster1, ltail = cluster0];
  b -> d;
  c -> d [ltail = cluster0];
  c -> f [lhead = cluster1];
}
    end_of_string
  end

  def test_undirected_graph
    gvr = GraphvizR.new 'sample'
    gvr.alpha - gvr.beta
    (gvr.beta - gvr.gamma) [:label => 'label2']

    assert_equal <<-end_of_string, gvr.to_dot
graph sample {
  alpha -- beta;
  beta -- gamma [label = "label2"];
}
    end_of_string
  end

  def test_undirected_subgraph
    gvr = GraphvizR.new 'sample'
    gvr.cluster0 do |c0|
      c0.graph [:color => :blue, :label => 'area 0', :style => :bold]
      c0.a - c0.b
      c0.a - c0.c
    end
    gvr.cluster1 do |c1|
      c1.graph [:fillcolor => '#cc9966', :label => 'area 1', :style => :filled]
      c1.d - c1.e
      c1.d - c1.f
    end
    (gvr.a - gvr.f) [:lhead => :cluster1, :ltail => :cluster0]
    gvr.b - gvr.d
    (gvr.c - gvr.d) [:ltail => :cluster0]
    (gvr.c - gvr.f) [:lhead => :cluster1]

    assert_equal <<-end_of_string, gvr.to_dot
graph sample {
  subgraph cluster0 {
    graph [color = blue, label = "area 0", style = bold];
    a -- b;
    a -- c;
  }
  subgraph cluster1 {
    graph [fillcolor = "#cc9966", label = "area 1", style = filled];
    d -- e;
    d -- f;
  }
  a -- f [lhead = cluster1, ltail = cluster0];
  b -- d;
  c -- d [ltail = cluster0];
  c -- f [lhead = cluster1];
}
    end_of_string
  end

  def test_consective_edges
    gvr = GraphvizR.new 'sample'
    gvr.alpha >> gvr.beta
    gvr.alpha >> gvr.beta >> gvr.gamma
    gvr.alpha >> gvr.beta >> gvr.gamma >> gvr.delta

    assert_equal <<-end_of_string, gvr.to_dot
digraph sample {
  alpha -> beta;
  alpha -> beta -> gamma;
  alpha -> beta -> gamma -> delta;
}
    end_of_string
  end

  def test_consective_undirected_edges
    gvr = GraphvizR.new 'sample'
    gvr.alpha - gvr.beta
    gvr.alpha - gvr.beta - gvr.gamma
    gvr.alpha - gvr.beta - gvr.gamma - gvr.delta

    assert_equal <<-end_of_string, gvr.to_dot
graph sample {
  alpha -- beta;
  alpha -- beta -- gamma;
  alpha -- beta -- gamma -- delta;
}
    end_of_string
  end

  def test_node_grouping
    gvr = GraphvizR.new 'sample'
    gvr.alpha >> [gvr.beta, gvr.gamma, gvr.delta]

    assert_equal <<-end_of_string, gvr.to_dot
digraph sample {
  alpha -> {beta; gamma; delta;};
}
    end_of_string
  end

  def test_node_grouping_reverse
    gvr = GraphvizR.new 'sample'
    [gvr.beta, gvr.gamma, gvr.delta] >> gvr.alpha

    assert_equal <<-end_of_string, gvr.to_dot
digraph sample {
  {beta; gamma; delta;} -> alpha;
}
    end_of_string
  end

  def test_consective_node_grouping
    gvr = GraphvizR.new 'sample'
    gvr.alpha >> gvr.beta >> [gvr.gamma, gvr.delta]

    assert_equal <<-end_of_string, gvr.to_dot
digraph sample {
  alpha -> beta -> {gamma; delta;};
}
    end_of_string
  end

  def test_intermediate_defaults
    gvr = GraphvizR.new 'example'
    gvr.dummy1 [:label => 'dummy1']
    gvr.graph [:size => "3, 3"]
    gvr.dummy2 [:label => 'dummy2']
    gvr.node [:shape => :box]
    gvr.dummy3 [:label => 'dummy3']
    gvr.edge [:fontcolor => :red]
    gvr.dummy4 [:label => 'dummy4']

    assert_equal <<-end_of_string, gvr.to_dot
digraph example {
  dummy1 [label = "dummy1"];
  graph [size = "3, 3"];
  dummy2 [label = "dummy2"];
  node [shape = box];
  dummy3 [label = "dummy3"];
  edge [fontcolor = red];
  dummy4 [label = "dummy4"];
}
    end_of_string
  end

  def test_rank
    gvr = GraphvizR.new 'sample'
    gvr.rank :same, [gvr.Level_1, gvr.a]

    assert_equal <<-end_of_string, gvr.to_dot
digraph sample {
  {rank = same; Level_1; a;};
}
    end_of_string
  end

=begin
  def test_rank_new
    gvr = GraphvizR.new 'sample'
    gvr.group {|gvr| gvr.rank = :same, gvr.Level_1, gvr.a}

    assert_equal <<-end_of_string, gvr.to_dot
digraph sample {
  {rank = same; Level_1; a;};
}
    end_of_string
  end
=end

  def test_data
    gvr = GraphvizR.new 'sample'
    gvr.graph [:label => 'example', :size => '1.5, 2.5'] 
    gvr.beta [:shape => :box]                            
    gvr.alpha >> gvr.beta
    (gvr.alpha >> gvr.gamma) [:label => 'label1']
    (gvr.beta >> gvr.delta) [:label => 'label2']
    gvr.delta >> gvr[:size]

    assert_equal <<-end_of_string, gvr.data(:dot)
digraph sample {
  graph [label = "example", size = "1.5, 2.5"];
  beta [shape = box];
  alpha -> beta;
  alpha -> gamma [label = "label1"];
  beta -> delta [label = "label2"];
  delta -> size;
}
    end_of_string
  end

  def test_left_aligned_text_in_record_nodes
    gvr = GraphvizR.new 'sample'
    gvr.node [:shape => 'record']
    gvr.node1 [:label => "Object|left\eright\rcentered\n"]  

    assert_equal <<-'end_of_string', gvr.data(:dot)
digraph sample {
  node [shape = "record"];
  node1 [label = "Object|left\lright\rcentered\n"];
}
    end_of_string
  end
end
