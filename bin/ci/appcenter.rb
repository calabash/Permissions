#!/usr/bin/env ruby
require "luffa"
require "pry"
require 'open3'
require "parallel"

AC_TOKEN= `#{Dir.home}/.calabash/find-keychain-credential.sh api-token`.chomp

def main
  semaphore = Mutex.new
  languages = ["da_DK","ru_RU","en_US","ja_JP"]
  results = Parallel.map(languages, in_threads: 4) do |item|
    cmd = `appcenter test run calabash --app-path testcloud-submit/Permissions.ipa --app App-Center-Test-Cloud/Permissions --project-dir testcloud-submit --token #{AC_TOKEN} --test-series master --devices "App-Center-Test-Cloud/daily-ios" --locale #{item} --config-path cucumber.yml --profile default --disable-telemetry`
    semaphore.synchronize {
      puts item
      puts cmd
    }
  end
  # languages = ["da_DK","ru_RU","en_US","ja_JP"]
  # threads = []
  # languages.each do |lang|
  #   threads << Thread.new(lang) do |item| 
  #     cmd = `appcenter test run calabash --app-path testcloud-submit/Permissions.ipa --app App-Center-Test-Cloud/Permissions --project-dir testcloud-submit --token #{AC_TOKEN} --test-series master --devices "App-Center-Test-Cloud/daily-ios" --locale #{item} --config-path cucumber.yml --profile default --disable-telemetry`
  #     # ' > $TEMP/#{lang}.out'

  #     # stdout, stderr, status = Open3.capture3(cmd)
  #     # puts "exit code language #{item} #{stdout}"
  #     # puts "status #{status}"
  #     # puts "stderr #{stderr}"    
  #     puts cmd
  #   end
  # end
  # threads.each { |thr| thr.join }
end

main