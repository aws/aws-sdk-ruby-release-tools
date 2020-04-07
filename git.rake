# frozen_string_literal: true

require 'rake'
require_relative 'utils'

namespace :git do

  desc 'Ensure that the workspace is in a good state to release'
  idempotent_task :check_workspace do
    Rake::Task['git:require_clean_workspace'].execute
    Rake::Task['git:require_master'].execute
    Rake::Task['git:require_up_to_date'].execute
  end

  # Ensure the git repo is free of unstaged or untracked files prior
  # to building / testing / pushing a release.
  task :require_clean_workspace do
    unless `git diff --shortstat -ignore-submodules 2> /dev/null | tail -n1` == ''
      warn('workspace must be clean to release')
      exit(1)
    end
  end

  # Ensure the git repo is on master
  task :require_master do
    status = `git status --porcelain=v2 --branch 2> /dev/null`
    unless status.include? 'branch.ab +0 -0'
      warn('workspace must be in sync with remote origin/master branch to release')
      exit(1)
    end
  end

  # Ensure the git repo is up to
  task :require_up_to_date do
    status = `git fetch && git status --porcelain=v2 --branch 2> /dev/null`
    unless status.include? 'branch.upstream origin/master'
      warn('workspace must be on master branch to release')
      exit(1)
    end
  end

  task :tag do
    sh("git commit -m \"Bumped version to v#{$VERSION}\"")
    sh("git tag -a -m \"$(rake git:tag_message)\" v#{$VERSION}")
  end

  task :tag_message do
    issues = `git log $(git describe --tags --abbrev=0)...HEAD -E \
              --grep '#[0-9]+' 2>/dev/null`
    issues = issues.scan(%r{((?:\S+/\S+)?#\d+)}).flatten
    msg = +"Tag release v#{$VERSION}"
    msg << "\n\n"
    unless issues.empty?
      msg << "References: #{issues.uniq.sort.join(', ')}"
      msg << "\n\n"
    end
    msg << `rake changelog:latest`
    puts msg
  end

  task :push do
    sh('git push origin')
    sh('git push origin --tags')
  end
end
