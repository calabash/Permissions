#!/usr/bin/env ruby

require "run_loop"
require "luffa"
require "pry"


cucumber_args = "#{ARGV.join(" ")}"

this_dir = File.expand_path(File.dirname(__FILE__))
working_directory = File.join(this_dir, "..", "..")


def which_languages(cucumber_args)
  if cucumber_args.nil? || cucumber_args.empty?
    cucumber_args = ["APP_LANG=ru APP_LOCALE=ru",
    "APP_LANG=en APP_LOCALE=en"]
    return cucumber_args
  end
  return [cucumber_args]
end



# on-simulator tests of features in test/cucumber
Dir.chdir(working_directory) do

  FileUtils.rm_rf("reports")
  FileUtils.mkdir_p("reports")

  Luffa.unix_command("make clean",
                     {:pass_msg => "cleaned",
                      :fail_msg => "could not clean"})

  Luffa.unix_command("make app",
                     {:pass_msg => "built app",
                      :fail_msg => "could not build app"})


  # Luffa.unix_command('export APP_LANG=ru')
  # Luffa.unix_command('export APP_LOCALE=ru')

  xcode = RunLoop::Xcode.new
  RunLoop::CoreSimulator.terminate_core_simulator_processes
  device = RunLoop::Core.default_simulator(xcode)
  device = device.gsub! ' ', ''
  device = device.gsub! '(', ''
  device = device.gsub! ')', ''
  
  cucumber_args= which_languages(cucumber_args)

  binding.pry
  cucumber_args.each do |item|
    args = [
      "bundle", "exec",
      "cucumber", "-p", "default",
      "-f", "json", "-o", "reports/#{device}.json",
      "-f", "junit", "-o", "reports/junit",
      "#{item}"
    ]

    identifier = RunLoop::Core.default_simulator(xcode)
    simctl = RunLoop::Simctl.new
    instruments = RunLoop::Instruments.new
    options = {}
    match = RunLoop::Device.detect_device(options, xcode, simctl, instruments)
    # RunLoop::CoreSimulator.set_locale(match, "ru")
    # RunLoop::CoreSimulator.set_language(match, "ru")
    env_vars = {"DEVICE_TARGET" => match.udid}
    cucumber_args
    exit_code = Luffa.unix_command(args.join(" "), {:exit_on_nonzero_status => false,
                                                :env_vars => env_vars})
  end
end
