# frozen_string_literal: true

require_relative 'release_utils'

namespace :github do
  desc 'Check for a Github aaccess token'
  task :require_access_token do
    puts 'TASK START: github:require_access_token'
    unless ENV['AWS_SDK_FOR_RUBY_GH_TOKEN']
      warn('Github credentials for the automation account are required.: ' \
           "export ENV['AWS_SDK_FOR_RUBY_GH_TOKEN']")
      exit(1)
    end
    puts 'TASK END: github:require_access_token'
  end

  desc 'Push a new github release'
  idempotent_task :release do
    puts 'TASK START: github:release'
    require 'octokit'

    gh = Octokit::Client.new(access_token: ENV.fetch(
      'AWS_SDK_FOR_RUBY_GH_TOKEN', nil
    ))

    repo = `git remote get-url origin`
           .sub('ssh://', '')
           .sub('git@github.com:', '')
           .sub(".git\n", '').chomp
    tag_ref_sha = `git show-ref v#{$VERSION}`.split.first
    tag = gh.tag(repo, tag_ref_sha)

    name = "Release v#{$VERSION} - #{tag.tagger.date.strftime('%Y-%m-%d')}"
    release = gh.create_release(
      repo, "v#{$VERSION}",
      name: name,
      body: tag.message,
      prerelease: $VERSION.match('rc') ? true : false
    )

    gh.upload_asset(
      release.url,
      "#{gem_name}-#{$VERSION}.gem",
      content_type: 'application/octet-stream'
    )
    puts 'TASK END: github:release'
  end
end
