def person
  @person || Factory.create(:person)
end

Given /^a NetLogo model named "([^\"]*)"$/ do |model_name|
  @node = Factory.create(:node,
                         :name => model_name,
                         :visibility_id => 1,
                         :changeability_id => 1)

  @node_version = Factory.create(:node_version,
                                 :node => @node,
                                 :person => person)
end

When /^I attach a model file to "([^\"]*)"$/ do |file_upload_element_id|
  attach_file(file_upload_element_id, File.join(RAILS_ROOT, 'features', 'upload_files', 'test.nlogo'))
end

When /^I attach a preview image$/ do
  attach_file(:new_model_uploaded_preview, File.join(RAILS_ROOT, 'features', 'upload_files', 'test.png'))
end

When /^the model "([^\"]*)" should have (\d+) versions$/ do |model_name, number_of_versions|
  Node.find_by_name(model_name).node_versions.length.should == number_of_versions.to_i
end

When /^the model "([^\"]*)" should have (\d+) child(ren)?$/ do |model_name, number_of_children, ignore|
  Node.find_by_name(model_name).children.length.should == number_of_children.to_i
end
