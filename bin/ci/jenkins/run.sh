#!/usr/bin/env bash

set -e

bundle update
bin/ci/make-ipa.sh
bundle exec bin/test/test-cloud.rb
bundle exec bin/ci/cucumber.rb

