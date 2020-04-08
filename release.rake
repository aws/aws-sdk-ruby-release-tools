# frozen_string_literal: true

require_relative 'release_tool_utils'
require 'rake'

desc 'Public release, `VERSION=x.y.z rake release`'
task release: [
  'git:check_workspace',
  'release:check',
  'test',
  'release:build',
  'release:publish',
  'release:cleanup'
]

namespace :release do

  desc 'ensures all of the required credentials are present'
  task check: [
    'release:require_version',
    'github:require_access_token',
    'gems:require_credentials'
  ]

  desc 'require new version to be set'
  task :require_version do
    unless ENV['VERSION']
      warn('usage: VERSION=x.y.z rake release')
      exit
    end
  end

  desc 'bumps the VERSION file'
  idempotent_task :bump_version do
    sh("echo '#{$VERSION}' > VERSION")
    sh('git add VERSION')
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
    Rake::Task['git:tag'].execute
    Rake::Task['git:push'].execute
  end

  desc 'Adds new, clean unreleased changes section and pushes it'
  idempotent_task :next_release do
    Rake::Task['changelog:unreleased_changes'].execute
    Rake::Task['git:push'].execute
  end

  desc 'post release tasks'
  task :cleanup do
    sh('rm -rf .release')
  end
end
