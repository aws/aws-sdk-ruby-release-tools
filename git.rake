# frozen_string_literal: true

require_relative 'release_tool_utils'

namespace :git do
  desc 'Ensure that the workspace is in a good state to release'
  idempotent_task :check_workspace do
    Rake::Task['git:require_clean_workspace'].execute
    Rake::Task['git:require_main'].execute
    Rake::Task['git:require_up_to_date'].execute
  end

  desc 'Ensure the git repo is free of unstaged or untracked files'
  task :require_clean_workspace do
    status = `git diff --shortstat -ignore-submodules 2> /dev/null | tail -n1`
    unless status == ''
      warn('workspace must be clean to release')
      exit(1)
    end
  end

  desc 'Ensure the git repo is on main'
  task :require_main do
    status = `git status --porcelain=v2 --branch 2> /dev/null`
    unless status.include? 'branch.ab +0 -0'
      warn('workspace must be in sync with remote ' \
        'origin/main branch to release')
      exit(1)
    end
  end

  desc 'Ensure the git repo is up to date/in sync with origin'
  task :require_up_to_date do
    status = `git fetch && git status --porcelain=v2 --branch 2> /dev/null`
    unless status.include? 'branch.upstream origin/main'
      warn('workspace must be on main branch to release')
      exit(1)
    end
  end

  desc 'Add a tag of the version release'
  task :tag do
    sh("git commit -m \"Bumped version to v#{$VERSION}\"")
    # Don't use interpolation here: changelog entries often have
    # backticks for formatting, and those will get run as commands
    # here otherwise.
    sh("git tag -a -m \"#{tag_message.gsub('`', '\\`')}\" v#{$VERSION}")
  end

  desc 'Push local changes and tags to the origin'
  task :push do
    sh('git push origin')
    sh('git push origin --tags')
  end
end
