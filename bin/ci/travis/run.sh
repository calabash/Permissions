#!/usr/bin/env bash

set -e

bundle update
bundle exec bin/ci/cucumber.rb

