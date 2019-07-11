#!/usr/bin/env ruby

require "luffa"
require "run_loop"
require "bundler"

device_set = ENV["XTC_DEVICE_SET"]

if !device_set || device_set == ""
  device_set = ARGV[0]
end

# iOS 8 - iOS 10
if !device_set || device_set == ""
  device_set = ["58194ce5", "5cedb29c", "9a0d9999", "b4ff432e"].sample
end


Bundler.with_clean_env do
  Luffa.unix_command("bundle update")

  # Ensure the latest DeviceAgent is installed.
  run_loop_gem = `bundle show run_loop`.strip
  Dir.chdir(run_loop_gem) do
    `rake device_agent:expand`
  end

  if !Luffa::Environment.travis_ci? && !Luffa::Environment.jenkins_ci?
    # For submitting tests locally
    Luffa.unix_command("make ipa")
    Luffa.unix_command("bundle exec briar xtc #{device_set}")
  else

    # Only maintainers can submit XTC tests.
    if Luffa::Environment.travis_ci? && ENV["TRAVIS_SECURE_ENV_VARS"] != "true"
      Luffa.log_info("Skipping XTC submission; non-maintainer activity")
      exit 0
    end

    # Previous steps do:
    # 1. bundle update
    # 1. install the TestCloudDev.keychain
    # 2. install .env
    # 3. make the ipa
    # 4. stage the ipa

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

