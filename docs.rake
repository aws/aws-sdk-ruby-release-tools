# frozen_string_literal: true
require_relative 'utils'

desc 'Delete the locally generated docs.' if ENV['ALL']
task 'docs:clobber' do
  rm_rf '.yardoc'
  rm_rf 'doc'
  rm_rf 'docs.zip'
end

desc 'Generates docs.zip'
task 'docs:zip' => 'docs' do
  sh('zip -9 -r -q docs.zip doc/')
end

desc 'Generate doc files.'
task 'docs' => 'docs:clobber' do
  env = {}
  env['SOURCE'] = '1'
  env['SITEMAP_BASEURL'] = 'http://docs.aws.amazon.com/awssdkrubyrecord/api/'
  sh(env, 'bundle exec yard')
end
