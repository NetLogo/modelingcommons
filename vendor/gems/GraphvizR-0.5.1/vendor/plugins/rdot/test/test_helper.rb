RAILS_ENV = 'test'

def __DIR__; File.dirname(__FILE__); end

def require_gem_or_lib(component)
  begin
    require_gem component
  rescue LoadError
    $:.unshift(__DIR__ + '/../../../rails/' + component.split('/')[0].gsub('_', '') + '/lib')
    require component
  end
end

require 'test/unit'
$:.unshift(__DIR__ + '/../lib')
begin
  require 'rubygems'
rescue LoadError
  $:.unshift(__DIR__ + '/../../../rails/activesupport/lib')
  $:.unshift(__DIR__ + '/../../../rails/activerecord/lib')
  $:.unshift(__DIR__ + '/../../../rails/actionpack/lib')
end

#require_gem_or_lib 'activesupport'
#require_gem_or_lib 'active_record'
#require_gem_or_lib 'action_controller'
#require_gem_or_lib 'action_controller/test_process'
require '/usr/lib/ruby/gems/1.8/gems/activesupport-1.3.1/lib/active_support'
require '/usr/lib/ruby/gems/1.8/gems/activerecord-1.14.4/lib/active_record'
require '/usr/lib/ruby/gems/1.8/gems/actionpack-1.12.5/lib/action_controller'
require '/usr/lib/ruby/gems/1.8/gems/actionpack-1.12.5/lib/action_controller/test_process'


config_file =
  if File.exist?(__DIR__ + '/../../../../config/database.yml')
    __DIR__ + '/../../../../config/database.yml'
  else
    __DIR__ + '/../config/database.yml'
  end

ActiveRecord::Base.establish_connection(YAML.load(ERB.new(File.read(config_file)).result)[RAILS_ENV])

ActionController::Routing::Routes.reload rescue nil
class ActionController::Base; def rescue_action(e) raise e end; end

logfile      = __DIR__ + '/log/rdot.log'
File.unlink(logfile) if File.exists?(logfile)
logger       = Logger.new(logfile)
logger.level = Logger::DEBUG
ActionController::Base.logger = logger

require __DIR__ + '/../init'
