require "bundler/gem_tasks"
require 'rubygems'
require 'rake'
require 'rake/testtask'

require File.dirname(__FILE__) + '/lib/trustcommerce'
require File.dirname(__FILE__) + '/lib/trustcommerce/version'

task :default => :test

Rake::TestTask.new(:test) { |t|
  t.libs << 'test'
  t.test_files = Dir.glob('test/*_test.rb')
  t.verbose = true
}