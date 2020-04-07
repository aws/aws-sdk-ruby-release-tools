# frozen_string_literal: true

require_relative 'utils'

namespace :github do
  task :require_access_token do
    unless ENV['AWS_SDK_FOR_RUBY_GH_TOKEN']
      warn("Github credentials for the automation account are required.: export ENV['AWS_SDK_FOR_RUBY_GH_TOKEN']")
      exit
    end
  end
  
  # This task must be defined to deploy
  task 'access-token'
  
  idempotent_task :release do
    require 'octokit'
  
    gh = Octokit::Client.new(access_token: ENV['AWS_SDK_FOR_RUBY_GH_TOKEN'])

    repo = `git remote get-url origin`.sub("git@github.com:", "").sub(".git\n", "")
    tag_ref_sha = `git show-ref v#{$VERSION}`.split(' ').first
    tag = gh.tag(repo, tag_ref_sha)

    release = gh.create_release(
      repo, "v#{$VERSION}",
      name: 'Release v' + $VERSION + ' - ' + tag.tagger.date.strftime('%Y-%m-%d'),
      body: tag.message + "\n" + `rake changelog:latest`,
      prerelease: $VERSION.match('rc') ? true : false
    )

    gh.upload_asset(release.url, "#{gem_name}-#{$VERSION}.gem",
                    content_type: 'application/octet-stream')
  end
  
  task 'access_token'
end
