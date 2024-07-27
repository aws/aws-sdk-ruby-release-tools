# frozen_string_literal: true

require_relative 'release_utils'

desc 'Public release, `VERSION=x.y.z rake release`'
task release: [
  'git:check_workspace',
  'release:check',
  'release:test',
  'release:build',
  'release:publish',
  'release:cleanup'
]

namespace :release do
  desc 'ensures all of the required credentials are present'
  task check: [
    'release:require_release_test_task',
    'release:require_version',
    'github:require_access_token',
    'gems:require_credentials'
  ]

  desc 'require release:test to be defined'
  task :require_release_test_task do
    puts 'TASK START: release:require_release_test_task'
    unless Rake::Task.task_defined?('release:test')
      raise 'Missing task release:test. Implement a release:test task that ' /
            'runs tests (unit and/or integration) that are required for ' /
            'release.'
    end
    puts 'TASK END: release:require_release_test_task'
  end

  desc 'require new version to be set'
  task :require_version do
    puts 'TASK START: release:require_version'
    unless ENV['VERSION']
      warn('usage: VERSION=x.y.z rake release')
      exit
    end
    puts 'TASK END: release:require_version'
  end

  desc 'bumps the VERSION file'
  idempotent_task :bump_version do
    puts 'TASK START: release:bump_version'
    sh("echo '#{$VERSION}' > VERSION")
    sh('git add VERSION')
    puts 'TASK END: release:bump_version'
  end

  desc 'builds release artifacts'
  task build: [
    'release:require_version',
    'changelog:version',
    'release:bump_version',
    'gems:build',
    'docs:zip'
  ]

  desc 'deploys release artifacts'
  task publish: [
    'release:check',
    'gems:push',
    'release:push_version',
    'github:release',
    'release:next_release'
  ]

  desc 'Tags and pushes the version updates'
  idempotent_task :push_version do
    puts 'TASK START: release:push_version'
    Rake::Task['git:tag'].execute
    Rake::Task['git:push'].execute
    puts 'TASK END: release:push_version'
  end

  desc 'Adds new, clean unreleased changes section and pushes it'
  idempotent_task :next_release do
    puts 'TASK START: release:next_release'
    Rake::Task['changelog:unreleased_changes'].execute
    Rake::Task['git:push'].execute
    puts 'TASK END: release:next_release'
  end

  desc 'post release tasks'
  task :cleanup do
    puts 'TASK START: release:clean_up'
    sh('rm -rf .release')
    puts 'TASK END: release:clean_up'
  end
end
