require 'rubygems'
require 'ruby-debug'

RAILS_ENV = 'test'

# Load Rails
require 'active_support'
require 'action_controller'
require 'action_mailer'
require 'rails/version'

RAILS_ROOT = File.join(File.dirname(__FILE__), 'application')
$:.unshift(RAILS_ROOT)

ActionController::Base.view_paths = RAILS_ROOT
require File.join(RAILS_ROOT, 'application')

require 'inherited_resources'
require 'inherited_resources/base_helpers'

ActiveSupport::Dependencies.load_paths << File.join(File.dirname(__FILE__), '..', 'lib')
require_dependency 'auth_helpers'

require 'spec/rails'
require 'remarkable_rails'
