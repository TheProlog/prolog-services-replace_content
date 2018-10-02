
require "bundler/gem_tasks"
require "rake/testtask"

require 'rake/tasklib'
require 'flay_task'
require 'flog'
require 'flog_task'
require 'reek/rake/task'
require 'rubocop/rake_task'

Rake::TestTask.new(:test) do |t|
  t.ruby_opts << '-W0'
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList['test/**/*_test.rb']
end

RuboCop::RakeTask.new(:rubocop) do |task|
  task.patterns = [
    'lib/**/*.rb',
    'test/**/*.rb'
  ]
  task.formatters = ['simple', 'd']
  task.fail_on_error = true
  # task.options << '--rails'
  task.options << '--display-cop-names'
end

Reek::Rake::Task.new do |t|
  t.config_file = 'config.reek'
  t.source_files = '{app,lib,test}/**/*.rb'
  t.reek_opts = '--sort-by smelliness -s'
end

FlayTask.new do |t|
  t.verbose = true
  t.dirs = %w(app lib)
end

FlogTask.new do |t|
  t.verbose = true
  t.threshold = 200 # default is 200
  t.instance_variable_set :@methods_only, true
  t.dirs = %w(app lib) # Look, Ma; no tests! Run the tool manually every so often for those.
end

task(:default).clear
task default: [:test, :rubocop, :flay, :flog, :reek]
