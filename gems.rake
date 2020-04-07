# frozen_string_literal: true

require_relative 'utils'

namespace :gems do
  task :build do
    sh('rm -f *.gem')
    sh("gem build #{gem_name}.gemspec")
  end

  idempotent_task :push do
    sh("gem push #{gem_name}-#{$VERSION}.gem")
  end

  task :require_credentials do
    unless File.exists? File.expand_path('~/.gem/credentials')
      warn('RubyGems credentials are required in `~/.gem/credentials`')
      exit
    end
  end
end
