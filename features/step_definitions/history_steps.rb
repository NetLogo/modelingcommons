Given /I choose "([^\"]*)" for version (\d+)$/ do |which_compare, version_number|
  choose("#{which_compare}_#{@node.node_versions[version_number.to_i - 1].id}")
end
