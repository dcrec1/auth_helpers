Gem::Specification.new do |s|
  s.name     = "auth_helpers"
  s.version  = "0.2.1"
  s.date     = "2009-04-24"
  s.summary  = "AuthHelpers is a collection of modules to improve your Authlogic models."
  s.email    = "jose.valim@gmail.com"
  s.homepage = "http://github.com/josevalim/auth_helpers"
  s.description = "AuthHelpers is a collection of modules to improve your Authlogic models."
  s.has_rdoc = true
  s.authors  = [ "José Valim" ]
  s.files    = [
    "CHANGELOG",
    "MIT-LICENSE",
    "README",
    "init.rb",
    "lib/auth_helpers.rb",
    "lib/auth_helpers/notifier.rb",
    "lib/auth_helpers/controller/confirmable.rb",
    "lib/auth_helpers/controller/helpers.rb",
    "lib/auth_helpers/controller/recoverable.rb",
    "lib/auth_helpers/model/associatable.rb",
    "lib/auth_helpers/model/confirmable.rb",
    "lib/auth_helpers/model/recoverable.rb",
    "lib/auth_helpers/model/updatable.rb",
    "lib/auth_helpers/spec/associatable.rb",
    "lib/auth_helpers/spec/confirmable.rb",
    "lib/auth_helpers/spec/notifier.rb",
    "lib/auth_helpers/spec/recoverable.rb",
    "lib/auth_helpers/spec/updatable.rb",
    "views/auth_helpers/notifier/create_confirmation.erb",
    "views/auth_helpers/notifier/resend_confirmation.erb",
    "views/auth_helpers/notifier/reset_password.erb",
    "views/auth_helpers/notifier/update_confirmation.erb"
  ]
  s.rdoc_options = ["--main", "README"]
  s.extra_rdoc_files = ["README"]
  s.add_dependency("authlogic")
end
