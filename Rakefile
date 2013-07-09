
require 'rake/testtask'
require 'bundler/gem_tasks'

task :test do
  Bundler.require('test') if defined?(Bundler)
  Rake::TestTask.new do |t|
    t.libs << "lib"
    t.test_files = FileList['test/**/*_test.rb']
    t.verbose = true
  end
end

task :default => :test
