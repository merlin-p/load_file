require 'rspec/core/rake_task'
require 'bundler/gem_tasks'
require 'resque/tasks'

RSpec::Core::RakeTask.new(:spec) do |task|
  task.rspec_opts = ['--format', 'd']
end

task :default => :spec