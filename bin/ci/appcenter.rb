#!/usr/bin/env ruby
require "luffa"
require "json"

AC_TOKEN = `#{Dir.home}/.calabash/find-keychain-credential.sh api-token`.chomp

semaphore = Mutex.new
languages = ["da_DK", "ru_RU", "en_US", "ja_JP"]
threads = []
summary = {}
languages.each do |lang|
  threads << Thread.new(lang) do |item|
    output = `appcenter test run calabash --app-path testcloud-submit/Permissions.ipa --app App-Center-Test-Cloud/Permissions --project-dir testcloud-submit --token #{AC_TOKEN} --test-series master --devices "App-Center-Test-Cloud/v-malob-test-permissions" --locale #{item} --config-path cucumber.yml --profile default --disable-telemetry`
    semaphore.synchronize do
      puts "Run tests for language '#{item}'"
      puts output
      puts "Finished with exit code '#{$?.exitstatus}'"
      summary[item] = $?.exitstatus
    end
  end
end

threads.each { |thr| thr.join }

puts "Summary:"
JSON.pretty_generate(summary)

# exit 0 if all tests passed
exit summary.values.sum
