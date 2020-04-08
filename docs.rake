# frozen_string_literal: true
require_relative 'release_tool_utils'

namespace :docs do
  desc 'Delete the locally generated docs.'
  task :clobber  do
    rm_rf '.yardoc'
    rm_rf 'doc'
    rm_rf 'docs.zip'
  end

  desc 'Generates docs.zip'
  task zip: 'build' do
    sh('zip -9 -r -q docs.zip doc/')
  end

  desc 'Generate doc files.'
  task build: 'docs:clobber' do
    env = {}
    env['SOURCE'] = '1'
    env['SITEMAP_BASEURL'] = 'http://docs.aws.amazon.com/awssdkrubyrecord/api/'
    sh(env, 'bundle exec yard')
  end
end
