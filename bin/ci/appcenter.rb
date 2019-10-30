#!/usr/bin/env ruby
require "luffa"
require "pry"

AC_TOKEN= `#{Dir.home}/.calabash/find-keychain-credential.sh api-token`.chomp

def main
  languages = ["da_DK","ru_RU","en_US","ja_JP"]
  threads = []
  languages.each do |lang|
    threads << Thread.new(lang) do |item|
      # cmd = 'appcenter test run calabash' \
      # ' --app-path testcloud-submit/Permissions.ipa' \
      # ' --app App-Center-Test-Cloud/Permissions' \
      # ' --project-dir testcloud-submit' \
      # " --token #{AC_TOKEN}" \
      # " --test-series master" \
      # ' --devices "App-Center-Test-Cloud/daily-ios"' \
      # " --locale #{item}" \
      # ' --config-path cucumber.yml' \
      # ' --profile default' \
      # ' --disable-telemetry'
      # exit_code = Luffa.unix_command(cmd)
      cmd = `appcenter test run calabash
       --app-path testcloud-submit/Permissions.ipa
       --app App-Center-Test-Cloud/Permissions
       --project-dir testcloud-submit
       --token #{AC_TOKEN}
       --test-series master
       --devices "App-Center-Test-Cloud/daily-ios"
       --locale #{item}
       --config-path cucumber.yml
       --profile default
       --disable-telemetry`
      puts "exit code language #{item}"
      puts cmd
    end
  end
  threads.each { |thr| thr.join }
end

main