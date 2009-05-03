# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path(File.dirname(__FILE__) + "/../../../../config/environment") unless defined?(RAILS_ROOT)

require 'spec/autorun'
require 'spec/rails'
require 'remarkable_rails'

ActionController::Base.view_paths = File.join(File.dirname(__FILE__), 'views')

# Add the default routes
ActionController::Routing::Routes.draw do |map|
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
  map.new_accountable_session '/accountable/session', :controller => 'application', :action => 'index'
end

# This class is used to test the controllers and it's autodetected
class Accountable
  def self.human_name; "Accountable"; end
end

# Set to an unknown locale
I18n.locale = :unknown

Spec::Runner.configure do |config|
end
