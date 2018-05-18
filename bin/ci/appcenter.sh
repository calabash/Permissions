#!/usr/bin/env bash

source "bin/log.sh"

set +e
hash appcenter 2>/dev/null
if [ $? -eq 0 ]; then
  info "Using $(appcenter --version)"
else
  error "appcenter cli is not installed."
  error ""
  error "$ brew update; brew install npm"
  error "$ npm install -g appcenter-cli"
  error ""
  error "Then try again."
  exit 1
fi
set -e

if [ ! -e "${HOME}/.calabash/find-keychain-credential.sh" ]; then
  echo "Cannot find AppCenter token: no find-keychain-credential.sh script"
  echo "  ${HOME}/.calabash/find-keychain-credential.sh"
  exit 1
fi

if [ "${AC_TOKEN}" = "" ]; then
  AC_TOKEN=$("${HOME}/.calabash/find-keychain-credential.sh" api-token)
fi

IPA=Products/ipa/Permissions.ipa

appcenter test run calabash \
  --app-path testcloud-submit/Permissions.ipa \
  --app App-Center-Test-Cloud/Permissions \
  --project-dir testcloud-submit \
  --token $AC_TOKEN \
  --test-series develop \
  --devices App-Center-Test-Cloud/daily-ios \
  --config-path cucumber.yml \
  --profile default \
  --async \
  --disable-telemetry
