#!/usr/bin/env bash


# Force Xcode 8 CoreSimulator env to be loaded so xcodebuild does not fail.
set +e
for try in {1..4}; do
  xcrun simctl help &>/dev/null
  sleep 1.0
done

set -e

bundle update
bin/ci/make-ipa.sh
bundle exec bin/test/test-cloud.rb
bundle exec bin/ci/cucumber.rb
