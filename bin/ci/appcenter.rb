#!/usr/bin/env ruby

require "json"

AC_TOKEN = ENV['APPCENTER_ACCESS_TOKEN']
SOURCE_DIR = ENV['SOURCE_DIRECTORY']

semaphore = Mutex.new
languages = ["da_DK", "ru_RU", "en_US", "ja_JP"]
threads = []
summary = {}

#calabash tests
languages.each do |lang|
  threads << Thread.new(lang) do |item|
    args = ['--app-path testcloud-submit/Permissions.ipa',
    '--app App-Center-Test-Cloud/Permissions',
    '--project-dir testcloud-submit',
    "--token #{AC_TOKEN}",
    '--test-series master',
    '--devices "App-Center-Test-Cloud/daily-ios"',
    "--locale #{item}",
    "--config-path cucumber.yml",
    "--profile default",
    "--disable-telemetry"]
    output = `appcenter test run calabash #{args.join(' ')}`
    semaphore.synchronize do
      puts "Run tests for language '#{item}'"
      puts output
      puts "Finished with exit code '#{$?.exitstatus}'"
      puts "------------------------------------------"
      summary[item] = $?.exitstatus
    end
  end
end

#Xamarin.UITest test
threads << Thread.new("Xamarin.UITest_en_US") do |item|
  args = ['--app-path testcloud-submit/Permissions.ipa',
  "--app App-Center-Test-Cloud/Permissions",
  '--project-dir testcloud-submit',
  "--token #{AC_TOKEN}",
  '--devices "App-Center-Test-Cloud/daily-ios"',
  '--locale "en_US"',
  "--build-dir #{SOURCE_DIR}/Permissions_UITest/Permissions_UITest/bin/Debug/"]
  output = `appcenter test run uitest #{args.join(' ')}`
  semaphore.synchronize do
    puts "Run '#{item}' tests"
    puts output
    puts "Finished with exit code '#{$?.exitstatus}'"
    puts "------------------------------------------"
    summary[item] = $?.exitstatus
  end
end

threads.each { |thr| thr.join }

puts "Summary:"
puts JSON.pretty_generate(summary)

# exit 0 if all tests passed
exit summary.values.sum
