require 'bundler/setup'
require "bundler/gem_tasks"

require 'fileutils'
require 'rake/testtask'

# Test Task
Rake::TestTask.new do |t|
    t.libs << 'lib' << 'test'
    t.test_files = FileList['test/**/*_test.rb']
    # t.warning = true
    # t.verbose = true
end

Rake::TestTask.new('benchmark') do |t|
  t.libs << 'lib' << 'test'
  t.test_files = FileList['test/performance.rb']
  # t.warning = true
  # t.verbose = true
end
