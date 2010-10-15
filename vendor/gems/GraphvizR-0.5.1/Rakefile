# -*- ruby -*-

require 'rubygems'
require 'hoe'
require './lib/graphviz_r.rb'

Hoe.new('GraphvizR', GraphvizR::VERSION) do |p|
  p.rubyforge_name = 'graphviz_r'
  p.summary = 'Graphviz wrapper for Ruby and Rails'
  p.description = p.paragraphs_of('README.txt', 2..-5).join("\n\n")
  p.url = p.paragraphs_of('README.txt', 0).first.split(/\n/)[2..-1]
  p.email = 'andyjpn@gmail.com'
  p.author = p.paragraphs_of('README.txt', 0).first.split(/\n/)[1].sub(/\s*by /, '')
  p.changes = p.paragraphs_of('History.txt', 0..1).join("\n\n")
end

# vim: syntax=Ruby
