require 'rubygems'
require 'rake/gempackagetask'
require 'rake/rdoctask'

gem 'rspec'
require 'spec/rake/spectask'

desc "Run the specs under spec"
Spec::Rake::SpecTask.new do |t|
  t.spec_opts = ['--options', "spec/spec.opts"]
  t.spec_files = FileList['spec/**/*_spec.rb']
end

Rake::RDocTask.new do |rdoc|
  rdoc.main     = "README"
  rdoc.rdoc_dir = "rdoc"
  rdoc.title    = "AuthHelpers"
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.options << '--line-numbers' << '--inline-source'
end
