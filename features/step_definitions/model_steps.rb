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

Given /^a NetLogo model named "([^\"]*)" uploaded by "([^\"]*)"$/ do |model_name, email_address|
  p = Person.find_by_email_address(email_address)

  @node = Factory.create(:node,
                         :name => model_name,
                         :visibility_id => 1,
                         :changeability_id => 1)

  @node_version = Factory.create(:node_version,
                                 :node => @node,
                                 :person => p)
end

Given /^a NetLogo model named "([^\"]*)" in the project "([^\"]*)"$/ do |model_name, project_name|
  @node = Factory.create(:node,
                         :name => model_name,
                         :visibility_id => 1,
                         :changeability_id => 1)

  @node_version = Factory.create(:node_version,
                                 :node => @node,
                                 :person => person)

  @project = Factory.create(:project,
                            :name => project_name)

  @project.nodes << @node
  @project.save!
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

Given /^(\d+) additional versions? of "([^\"]*)"$/ do |number_of_versions, model_name|
  @model = Node.find_by_name(model_name)
  @node_versions = []

  number_of_versions.to_i.times do
    @node_versions << Factory.create(:node_version,
                                     :node => @model,
                                     :person => person)
  end
end

Given /^a version of "([^\"]*)" with different content$/ do |model_name|
  @model = Node.find_by_name(model_name)

  @node_version = Factory.create(:node_version,
                                     :node => @model,
                                     :person => person,
                                     :file_contents => File.open(RAILS_ROOT + "/features/upload_files/test2.nlogo").readlines.join("\n"))
end

Given /^a node type of "([^\"]*)"$/ do |node_type|
  Factory.create(:node_type, :name => node_type)
end

Given /^I spill my guts$/ do
  STDERR.puts response.body
end

Given /^the response should be successful$/ do
  response.should be_success
end

Given /^the response should be of type "([^\"]*)"$/ do |mime_type|
  response.content_type.should == mime_type
end
