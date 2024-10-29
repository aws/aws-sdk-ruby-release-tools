# frozen_string_literal: true

require_relative 'release_utils'

namespace :docs do
  desc 'Delete the locally generated docs.'
  task :clobber do
    puts 'TASK START: docs:clobber'
    rm_rf '.yardoc', verbose: false
    rm_rf 'doc', verbose: false
    rm_rf 'docs.zip', verbose: false
    puts 'TASK END: docs:clobber'
  end

  desc 'Generates docs.zip'
  task zip: 'build' do
    puts 'TASK START: docs:build'
    sh('zip -9 -r -q docs.zip doc/')
    puts 'TASK END: docs:build'
  end

  desc 'Generate doc files.'
  task build: 'docs:clobber' do
    puts 'TASK START: build:docs:clobber'
    sh('bundle exec yard')
    puts 'TASK END: build:docs:clobber'
  end
end
