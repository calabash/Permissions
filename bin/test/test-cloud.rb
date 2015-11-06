#!/usr/bin/env ruby

require "luffa"
require "bundler"
require "run_loop"

device_set = ENV["XTC_DEVICE_SET"]

if !device_set || device_set == ""
  device_set = ARGV[0]
end

if !device_set || device_set == ""
  device_set = ["086866b4", "19dc29ac", "0dea10e8", "a044021a"].sample
end

if !Luffa::Environment.travis_ci? && !Luffa::Environment.jenkins_ci?
  # For submitting tests locally
  Luffa.unix_command("make ipa")
  Bundler.with_clean_env do
    Luffa.unix_command("bundle update")
    Luffa.unix_command("bundle exec briar xtc #{device_set}")
  end
elsif Luffa::Environment.jenkins_ci?
  # Not yet.
elsif Luffa::Environment.travis_ci?

  # Only maintainers can submit XTC tests.
  if ENV["TRAVIS_SECURE_ENV_VARS"] != "true"
    Luffa.log_info("Skipping XTC submission; non-maintainer activity")
    exit 0
  end

  # Previous Travis steps do:
  # 1. install cucumber/.env
  # 2. make the ipa
  # 3. stage the ipa

  Dir.chdir("cucumber") do
    Bundler.with_clean_env do
      Luffa.unix_command("bundle update")

      # rake install must succeed
      calabash_gem = `bundle show calabash-cucumber`.strip

      ["dylibs", "staticlib"].each do |lib_dir|
        FileUtils.mkdir_p(File.join(calabash_gem, lib_dir))
      end

      ["libCalabashDyn.dylib", "libCalabashDynSim.dylib"].each do |lib|
        target = File.join(calabash_gem, "dylibs", lib)
        File.open(target, "w") do |file|
          file.write(%q{
These files cannot have zero size.  There is a validation
step in the rake install script that will abort the build
if these files are missing.
                     })
        end
      end

      ["libFrankCalabash.a", "calabash.framework.zip"].each do |lib|
        target = File.join(calabash_gem, "staticlib", lib)
        File.open(target, "w") do |file|
          file.write(%q{
These files cannot have zero size.  There is a validation
step in the rake install script that will abort the build
if these files are missing.
                     })
        end
      end

      Luffa.unix_command("bundle exec briar xtc #{device_set}")
    end
  end
end

