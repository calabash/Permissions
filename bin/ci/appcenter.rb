#!/usr/bin/env bash
require "luffa"

AC_TOKEN=$("${HOME}/.calabash/find-keychain-credential.sh" api-token)
IPA=Products/ipa/Permissions.ipa

 def languages
  languages = ["da_DK","ru_RU","en_US","ja_JP"]
  threads = []
  languages.each do |item|
    threads << Thread.new(item) do |i|
      str = 'appcenter test run calabash' \
      ' --app-path testcloud-submit/Permissions.ipa' \
      ' --app App-Center-Test-Cloud/Permissions' \
      ' --project-dir testcloud-submit' \
      " --token #{AC_TOKEN}" \
      " --test-series master" \
      " --locale #{i}" \
      ' --devices App-Center-Test-Cloud/daily-ios' \
      ' --config-path cucumber.yml' \
      ' --profile default' \
      ' --async' \
      ' --disable-telemetry'
      exit_code = Luffa.unix_command(str)
      puts "exit code language #{i} is #{exit_code}"
    end
  end
  threads.each { |thr| thr.join }
end

languages