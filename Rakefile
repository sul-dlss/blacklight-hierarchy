#!/usr/bin/env rake
begin
  require 'bundler/setup'
  Bundler::GemHelper.install_tasks
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'engine_cart/rake_task'
TEST_APP_TEMPLATES = 'spec/test_app_templates'.freeze
TEST_APP = 'spec/internal'.freeze
# ZIP_URL = "https://github.com/projectblacklight/blacklight-jetty/archive/v4.0.0.zip"
APP_ROOT = File.expand_path('..', __FILE__)

task default: :ci

require 'rspec/core/rake_task'

desc 'Run specs'
RSpec::Core::RakeTask.new(:rspec)
task spec: :rspec

desc 'Execute Continuous Integration Build'
task ci: ['engine_cart:clean', 'engine_cart:generate', 'rspec']

begin
  require 'rdoc/task'
rescue LoadError
  require 'rdoc/rdoc'
  require 'rake/rdoctask'
  RDoc::Task = Rake::RDocTask
end

desc 'Create rdoc'
RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Blacklight::Hierarchy'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
