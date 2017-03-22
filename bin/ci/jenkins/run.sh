#!/usr/bin/env bash

set +e

export DEVELOPER_DIR=/Xcode/8.2.1/Xcode.app/Contents/Developer

# Load correct CoreSimulatorService
xcrun simctl help >/dev/null 2>&1
xcrun simctl help >/dev/null 2>&1
xcrun simctl help >/dev/null 2>&1

set -e

bundle update
bin/ci/make-ipa.sh
bundle exec bin/test/test-cloud.rb
bundle exec bin/ci/cucumber.rb

