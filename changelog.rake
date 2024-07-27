# frozen_string_literal: true

require_relative 'release_utils'

namespace :changelog do
  desc 'replaces "Unreleased Changes"" in the CHANGELOG with a version and date'
  idempotent_task :version do
    puts 'TASK START: changelog:version'
    changelog = File.open('CHANGELOG.md', 'r', encoding: 'UTF-8', &:read)
    changelog = changelog.lines.to_a
    unless changelog.first.include? 'Unreleased Changes'
      warn('The first line of changelog must match "Unreleased Changes"')
      exit(1)
    end
    changelog[0] = "#{$VERSION} (#{Time.now.strftime('%Y-%m-%d')})\n"
    changelog = changelog.join
    File.open('CHANGELOG.md', 'w', encoding: 'UTF-8') { |f| f.write(changelog) }
    sh('git add CHANGELOG.md')
    puts 'TASK END: changelog:version'
  end

  desc 'inserts an "Unreleased Changes" section at the top of the CHANGELOG'
  idempotent_task :unreleased_changes do
    puts 'TASK START: changelog:unreleased_changes'
    lines = []
    lines << "Unreleased Changes\n"
    lines << "------------------\n"
    lines << "\n"
    changelog = File.open('CHANGELOG.md', 'r', encoding: 'UTF-8', &:read)
    changelog = lines.join + changelog
    File.open('CHANGELOG.md', 'w', encoding: 'UTF-8') { |f| f.write(changelog) }
    sh('git add CHANGELOG.md')
    sh("git commit -m 'Added next release section to the changelog. [ci skip]'")
    puts 'TASK END: changelog:unreleased_changes'
  end
end
