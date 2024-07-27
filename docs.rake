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
    if Rake.application.tasks.map(&:name).include? 'docs:setup_env'
      Rake::Task['docs:setup_env'].execute
    else
      warn('The gem should define a "docs:setup_env" task to set the ' \
           'SITEMAP_BASEURL env and any other values needed for generation ' \
           'of docs for this gem')
    end
    sh('bundle exec yard')
    puts 'TASK END: build:docs:clobber'
  end
end
