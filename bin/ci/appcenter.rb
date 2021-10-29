#!/usr/bin/env ruby

require "json"

#AC_TOKEN = `#{Dir.home}/.calabash/find-keychain-credential.sh api-token`.chomp
#AC_TOKEN = %x[echo $(AppCenterAPITokenProd)]
param1 = ARGV[0]
AC_TOKEN = param1
#AC_TOKEN = %x[echo $(AC_TOKEN)]
puts "token=#{AC_TOKEN}"

semaphore = Mutex.new
languages = ["da_DK", "ru_RU", "en_US", "ja_JP"]
threads = []
summary = {}
languages.each do |lang|
  threads << Thread.new(lang) do |item|
    args = ['--app-path testcloud-submit/Permissions.ipa',
    '--app App-Center-Test-Cloud/Permissions',
    '--project-dir testcloud-submit',
    "--token #{AC_TOKEN}",
    '--test-series master',
    '--devices "App-Center-Test-Cloud/Calabash.iOS.CI"',
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

threads.each { |thr| thr.join }

puts "Summary:"
puts JSON.pretty_generate(summary)

# exit 0 if all tests passed
exit summary.values.sum
