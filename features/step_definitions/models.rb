Given /^a NetLogo model named "([^\"]*)"$/ do |model_name|
  # Create a node
  @node = Node.create(:node_type_id => 1,
                      :name => model_name,
                      :visibility_id => 1,
                      :changeability_id => 1)
  @node.save!

  # Create a node version
  @node_version = NodeVersion.create(:node_id => @node.id,
                                     :person_id => @person.id,
                                     :description => "Test description",
                                     :file_contents => "foo")
  @node_version.save!
end

Given /^a permission setting named "([^\"]*)" with a short form of "([^\"]*)"$/ do |permission_name, short_form|
  PermissionSetting.create(:name => permission_name,
                           :short_form => short_form)
end

