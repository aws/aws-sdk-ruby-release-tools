# frozen_string_literal: true

require_relative 'release_tool_utils'

namespace :gems do

  desc 'Build the gem'
  task :build do
    sh('rm -f *.gem')
    sh("gem build #{gem_name}.gemspec")
  end

  desc 'Push (release) the gem to RubyGems'
  idempotent_task :execute do
    sh("gem push #{gem_name}-#{$VERSION}.gem")
  end

  desc 'Check that gem credentials have been set'
  task :require_credentials do
    unless File.exist? File.expand_path('~/.gem/credentials')
      warn('RubyGems credentials are required in `~/.gem/credentials`')
      exit(1)
    end
  end
end
