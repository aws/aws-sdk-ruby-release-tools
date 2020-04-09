# frozen_string_literal: true
require_relative 'release_tool_utils'

namespace :docs do
  desc 'Delete the locally generated docs.'
  task :clobber  do
    rm_rf '.yardoc', verbose: false
    rm_rf 'doc', verbose: false
    rm_rf 'docs.zip', verbose: false
  end

  desc 'Generates docs.zip'
  task zip: 'build' do
    sh('zip -9 -r -q docs.zip doc/')
  end

  desc 'Generate doc files.'
  task build: 'docs:clobber' do
    if Rake.application.tasks.map(&:name).include? 'docs:setup_env'
      Rake::Task['docs:setup_env'].execute
    else
      warn('The gem should define a "docs:setup_env" task to set the '\
            'SITEMAP_BASEURL env and any other values needed for generation '\
            'of docs for this gem')
    end
    sh('bundle exec yard')
  end
end
