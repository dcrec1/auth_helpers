# Create an application controller to satisfy rspec-rails, a dummy controller
# and define routes.
#
class ApplicationController < ActionController::Base
end

# This class is used to test the controllers and it's autodetected
class Accountable
  def self.human_name; "Accountable"; end
end

# Add the default routes
ActionController::Routing::Routes.draw do |map|
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
  map.new_accountable_session '/accountable/session', :controller => 'application', :action => 'index'
end
