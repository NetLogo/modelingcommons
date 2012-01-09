= GraphvizR
by ANDO Yasushi
http://blog.technohippy.net/pages/products/graphviz_r/en

== DESCRIPTION:

Graphviz wrapper for Ruby. This can be used as a common library, a rails plugin and a command line tool.

== FEATURES/PROBLEMS:
  
GraphvizR is graphviz adapter for Ruby, and it can:
* generate a graphviz dot file,
* generate an image file by means of utilizing graphviz,
* interprete rdot file and generate an image file,
* and, generate a graph image file in rails application as a rails plugin.


== SYNOPSYS:

=== Command Line:

  bin/graphviz_r sample/record.rdot

=== In Your Code:
This ruby code:

  gvr = GraphvizR.new 'sample'
  gvr.graph [:label => 'example', :size => '1.5, 2.5'] 
  gvr.beta [:shape => :box]                            
  gvr.alpha >> gvr.beta
  (gvr.beta >> gvr.delta) [:label => 'label1']
  gvr.delta >> gvr.gamma
  gvr.to_dot

replies the dot code:
  
  digraph sample {
    graph [label = "example", size = "1.5, 2.5"];
    beta [shape = box];
    alpha -> beta;
    beta -> delta [label = "label1"];
    delta -> gamma;
  }

To know more detail, please see test/test_graphviz_r.rb

=== On Rails :

<b>use _render :rdot_ in controller</b>

  def show_graph
    render :rdot do
      graph [:size => '1.5, 2.5']
      node [:shape => :record]
      node1 [:label => "<p_left> left|<p_center>center|<p_right> right"]
      node2 [:label => "left|center|right"]
      node1 >> node2
      node1(:p_left) >> node2
      node2 >> node1(:p_center)
      (node2 >> node1(:p_right)) [:label => 'record']
    end
  end

<b>use rdot view template</b>

  class RdotGenController < ApplicationController
    def index
      @label1 = "<p_left> left|<p_center>center|<p_right> right"
      @label2 = "left|center|right"
    end
  end
  
  # view/rdot_gen/index.rdot
  graph [:size => '1.5, 2.5']
  node [:shape => :record]
  node1 [:label => @label1]
  node2 [:label => @label2]
  node1 >> node2
  node1(:p_left) >> node2
  node2 >> node1(:p_center)
  (node2 >> node1(:p_right)) [:label => 'record']

== DEPENDENCIES:

* Graphviz (http://www.graphviz.org)

== TODO:

== INSTALL:

* sudo gem install graphviz_r
* if you want to use this in ruby on rails
  * script/plugin install http://technohippy.net/svn/repos/graphviz_r/trunk/vendor/plugins/rdot 

== LICENSE:

(The MIT License)

Copyright (c) 2007 FIX

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
