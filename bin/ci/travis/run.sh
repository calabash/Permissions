#!/usr/bin/env bash

bundle update
bin/ci/make-framework.sh
bundle exec bin/ci/cucumber.rb
bin/ci/make-ipa.sh
bundle exec bin/test/test-cloud.rb

