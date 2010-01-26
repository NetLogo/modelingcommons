require 'ruby-debug'
require 'factory_girl'
Dir.glob(File.join(File.dirname(__FILE__), '../../spec/factories/*.rb')).each { |f| require f}
require 'pickle/world'
require 'pickle/path/world'
require 'pickle/email/world'

Before do
  Factory.create(:permission_setting, :id => 1, :short_form => 'a', :name => 'Everyone')
  Factory.create(:permission_setting, :id => 2, :short_form => 'u', :name => 'No one but yourself')
  Factory.create(:permission_setting, :id => 3, :short_form => 'g', :name => 'Members of your group')
end
