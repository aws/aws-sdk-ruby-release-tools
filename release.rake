# frozen_string_literal: true

require_relative 'utils'
require 'rake'

desc 'Public release, `VERSION=x.y.z rake release`'
task :release => [
  'git:check_workspace',
  'release:check',
  'test',
  'release:build',
  'release:publish',
  'release:cleanup'
]

namespace :release do

  # ensures all of the required credentials are present
  task :check => [
    'release:require_version',
    'github:require_access_token',
    'gems:require_credentials',
  ]

  task :require_version do
    unless ENV['VERSION']
      warn('usage: VERSION=x.y.z rake release')
      exit
    end
  end

  # bumps the VERSION file
  idempotent_task :bump_version do
    sh("echo '#{$VERSION}' > VERSION")
    sh('git add VERSION')
  end



  # builds release artifacts
  task :build => [
    'release:require_version',
    'changelog:version',
    'release:bump_version',
    'gems:build'
  ]

  # deploys release artifacts
  task :publish => [
    'release:check',
    'gems:push',
    'release:push_version',
    'github:release',
    'release:next_release'
  ]

  # Tags and pushes the version updates
  idempotent_task :push_version do
    Rake::Task['git:tag'].execute
    Rake::Task['git:push'].execute
  end

  # Adds new, clean unreleased changes section and pushes it
  idempotent_task :next_release do
    Rake::Task['changelog:next_release'].execute
    Rake::Task['git:push'].execute
  end

  # post release tasks
  task :cleanup do
    sh('rm -rf .release')
  end
end