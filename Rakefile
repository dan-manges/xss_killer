require "rake/testtask"

task :default => :test

Rake::TestTask.new do |t|
  t.pattern = "test/**/*_test.rb"
end

RAILS_VERSIONS = %w[2.1.1 2.1.0 2.0.2]
 
namespace :test do
  desc "test with multiple versions of rails"
  task :multi do
    RAILS_VERSIONS.each do |rails_version|
      puts "Testing with Rails #{rails_version}"
      sh "RAILS_VERSION='#{rails_version}' rake test > /dev/null 2>&1"
    end
  end
end

desc "pre-commit task"
task :pc => "test:multi"
