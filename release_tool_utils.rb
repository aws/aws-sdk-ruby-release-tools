require 'fileutils'

def gem_name
  gemspec_file = Dir.glob('*.gemspec').first
  gemspec_file.chomp '.gemspec'
end

def ensure_release_dir
  Dir.mkdir('.release') unless File.exist? '.release'
end

def idempotent_task(task_def)
  task task_def do |task|
    ensure_release_dir
    task_checkpoint_file = ".release/#{task}.completed"
    if File.exist? task_checkpoint_file
      puts "#{task} has already run for this release.  Skipping"
    else
      yield
      FileUtils.touch task_checkpoint_file
    end
  end
end

def tag_message
  issues = `git log $(git describe --tags --abbrev=0)...HEAD -E \
              --grep '#[0-9]+' 2>/dev/null`
  issues = issues.scan(%r{((?:\S+/\S+)?#\d+)}).flatten
  msg = "Tag release v#{ENV['VERSION']}"
  msg << "\n\n"
  unless issues.empty?
    msg << "References: #{issues.uniq.sort.join(', ')}"
    msg << "\n\n"
  end
  msg << changelog_latest
end

def changelog_latest
  # Returns the contents of the most recent CHANGELOG section
  changelog = File.open('CHANGELOG.md', 'r', encoding: 'UTF-8', &:read)
  lines = []
  changelog.lines.to_a[3..-1].each do |line|
    # match a version number followed by date eg: 3.0.5 (2019-10-17)
    break if line =~ /^\d+\.\d+\.\d+ [( ]\d\d\d\d-\d\d-\d\d[)]/

    lines << line
  end
  lines[0..-2].join
end
