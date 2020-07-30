# frozen_string_literal: true

require 'rspec/core/rake_task'

desc 'run unit tests'
RSpec::Core::RakeTask.new('test:unit') do |t|
  t.rspec_opts = "-I #{$REPO_ROOT}/lib -I #{$REPO_ROOT}/spec"
  t.pattern = "#{$REPO_ROOT}/spec"
end

desc 'run integration tests'
task 'test:integration' do |t|
  if ENV['AWS_INTEGRATION']
    exec('bundle exec cucumber')
  else
    puts 'Skipping integration tests'
    puts 'export AWS_INTEGRATION=1 to enable integration tests'
  end
end
