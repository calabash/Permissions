#!/usr/bin/env ruby

require "run_loop"

cucumber_args = "#{ARGV.join(" ")}"

this_dir = File.expand_path(File.dirname(__FILE__))
working_directory = File.join(this_dir, "..", "..")

# on-simulator tests of features in test/cucumber
Dir.chdir(working_directory) do

  FileUtils.rm_rf("reports")
  FileUtils.mkdir_p("reports")

  xcode = RunLoop::Xcode.new
  RunLoop::CoreSimulator.terminate_core_simulator_processes

  simctl = RunLoop::Simctl.new
  instruments = RunLoop::Instruments.new
  options = {}
  match = RunLoop::Device.detect_device(options, xcode, simctl, instruments)
  env_vars = {"DEVICE_TARGET" => match.udid}

  languagesLiterals = { "en" => "en_US", "ru" => "ru_RU" }

  failed_langs = []

  languagesLiterals.each do |key, value|
    env_vars["APP_LANG"] = key
    env_vars["APP_LOCALE"] = value

    args = [
      "bundle", "exec",
      "cucumber", "-p", "default",
      "-f", "junit", "-o", "reports/#{key}",
    ]

    if !system(env_vars, *args)
      failed_langs << key
    end
  end

  if failed_langs.count == 0
    puts "Cucumber tests passed for #{languagesLiterals.keys}"
    exit 0
  else
    puts "Cucumber tests failed for #{failed_langs}"
    exit 1
  end
end
