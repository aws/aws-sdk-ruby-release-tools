require 'fileutils'

def gem_name
  gemspec_file = Dir.glob('*.gemspec').first
  gemspec_file.chomp '.gemspec'
end

def ensure_release_dir
  Dir.mkdir('.release') unless File.exist? '.release'
end

def idempotent_task task_def
  task task_def do |task|
    ensure_release_dir
    task_checkpoint_file = ".release/#{task}.checkpoint"
    if File.exist? task_checkpoint_file
      puts "#{task} has already run for this release.  Skipping"
    else
      puts "Running: #{task}"
      yield
      FileUtils.touch task_checkpoint_file
    end
  end
end
