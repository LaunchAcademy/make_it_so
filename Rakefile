require "bundler/gem_tasks"

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:rspec)

desc 'Run the test suite'
task :default => :rspec

task :console do
  require 'irb'
  require 'irb/completion'
  require 'make_it_so' # You know what to do.
  ARGV.clear
  IRB.start
end
