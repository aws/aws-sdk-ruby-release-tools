# frozen_string_literal: true

require_relative 'utils'

namespace :github do
  task :require_access_token do
    unless ENV['AWS_SDK_FOR_RUBY_GH_TOKEN']
      warn('Github credentials for the automation account are required.: ' \
        "export ENV['AWS_SDK_FOR_RUBY_GH_TOKEN']")
      exit
    end
  end

  # TODO: Remove these after a successful release
  # We previously defined these as below
  # But they don't appear to be used anywhere
  # task 'access-token'
  # task 'access_token'

  idempotent_task :release do
    require 'octokit'

    gh = Octokit::Client.new(access_token: ENV['AWS_SDK_FOR_RUBY_GH_TOKEN'])

    repo = `git remote get-url origin`
           .sub('git@github.com:', '')
           .sub(".git\n", '')
    tag_ref_sha = `git show-ref v#{$VERSION}`.split(' ').first
    tag = gh.tag(repo, tag_ref_sha)

    name = "Release v#{$VERSION} - tag.tagger.date.strftime('%Y-%m-%d')"
    release = gh.create_release(
      repo, "v#{$VERSION}",
      name: name,
      body: tag.message + "\n" + `rake changelog:latest`,
      prerelease: $VERSION.match('rc') ? true : false
    )

    gh.upload_asset(release.url, "#{gem_name}-#{$VERSION}.gem",
                    content_type: 'application/octet-stream')
  end

end
