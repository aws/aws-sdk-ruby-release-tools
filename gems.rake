# frozen_string_literal: true

require_relative 'release_tool_utils'

namespace :gems do
  desc 'Build the gem'
  task :build do
    puts 'TASK START: gems:build'
    sh('rm -f *.gem')
    sh("gem build #{gem_name}.gemspec")
    puts 'TASK END: gems:build'
  end

  desc 'Push (release) the gem to RubyGems'
  idempotent_task :push do
    puts 'TASK START: gems:push'
    sh("gem push #{gem_name}-#{$VERSION}.gem")
    puts 'TASK END: gems:push'
  end

  desc 'Check that gem credentials have been set'
  task :require_credentials do
    puts 'TASK START: gems:require_credentials'
    unless File.exist? File.expand_path('~/.gem/credentials')
      warn('RubyGems credentials are required in `~/.gem/credentials`')
      exit(1)
    end
    puts 'TASK END: gems:require_credentials'
  end
end
