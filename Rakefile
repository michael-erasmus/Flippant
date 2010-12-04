require 'rake'
require 'rake/rdoctask'
require 'rspec/core'
require 'rspec/core/rake_task'


desc 'Default: run specs.'
task :default => :spec

desc 'Run specs for the steak plugin.'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.skip_bundler = true
  t.pattern = FileList["spec/**/*_spec.rb"]
end

