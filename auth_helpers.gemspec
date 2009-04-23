Gem::Specification.new do |s|
  s.name     = "auth_helpers"
  s.version  = "0.1.0"
  s.date     = "2009-04-23"
  s.summary  = "AuthHelpers is a collection of modules to include in your model to deal with authentication."
  s.email    = "jose.valim@gmail.com"
  s.homepage = "http://github.com/josevalim/auth_helpers"
  s.description = "AuthHelpers is a collection of modules to include in your model to deal with authentication."
  s.has_rdoc = true
  s.authors  = [ "José Valim" ]
  s.files    = [
    "CHANGELOG",
    "MIT-LICENSE",
    "README",
    "init.rb",
    "lib/auth_helpers.rb",
    "lib/auth_helpers/migration.rb",
    "lib/auth_helpers/notifier.rb",
    "lib/auth_helpers/model/associatable.rb",
    "lib/auth_helpers/model/authenticable.rb",
    "lib/auth_helpers/model/confirmable.rb",
    "lib/auth_helpers/model/recoverable.rb",
    "lib/auth_helpers/model/rememberable.rb",
    "lib/auth_helpers/model/validatable.rb",
    "lib/auth_helpers/spec/associatable.rb",
    "lib/auth_helpers/spec/authenticable.rb",
    "lib/auth_helpers/spec/confirmable.rb",
    "lib/auth_helpers/spec/notifier.rb",
    "lib/auth_helpers/spec/recoverable.rb",
    "lib/auth_helpers/spec/rememberable.rb",
    "lib/auth_helpers/spec/validatable.rb"
  ]
  s.rdoc_options = ["--main", "README"]
  s.extra_rdoc_files = ["README"]
  s.add_dependency("remarkable_rails", ">= 3.0.7")
end
