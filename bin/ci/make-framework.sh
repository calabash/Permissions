#!/usr/bin/env bash

if [ -z "${TRAVIS}" ] && [ -z "${JENKINS_HOME}" ]; then
  echo "FAIL: only run this script on Travis or Jenkins"
  exit 1
fi

if [ -n "${TRAVIS}" ] && [ "${TRAVIS_SECURE_ENV_VARS}" != "true" ]; then
  echo "INFO: skipping make framework; non-maintainer activity"
  exit 0
fi

function error {
  echo "$(tput setaf 1)ERROR: $1$(tput sgr0)"
}

function ditto_or_exit {
  ditto "${1}" "${2}"
  if [ "$?" != 0 ]; then
    error "Could not copy:"
    error "  source: ${1}"
    error "  target: ${2}"
    if [ ! -e "${1}" ]; then
      error "The source file does not exist"
      error "Did a previous xcodebuild step fail?"
    fi
    error "Exiting 1"
    exit 1
  fi
}

git clone \
  --recursive \
  --depth 1 \
  --branch develop \
  https://github.com/calabash/calabash-ios-server

(cd calabash-ios-server && make framework)

echo "path: ${PWD}"
rm -rf calabash.framework
ditto_or_exit calabash-ios-server/calabash.framework calabash.framework

