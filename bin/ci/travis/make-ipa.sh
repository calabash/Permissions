#!/usr/bin/env bash

if [ -z "${TRAVIS}" ]; then
  echo "FAIL: only run this script on Travis"
  exit 1
fi

if [ "${TRAVIS_SECURE_ENV_VARS}" != "true" ]; then
  echo "INFO: skipping keychain install; non-maintainer activity"
  exit 0
fi

bin/ci/travis/install-keychain.sh

CODE_SIGN_DIR="${HOME}/.calabash/calabash-codesign"
KEYCHAIN="${CODE_SIGN_DIR}/ios/Calabash.keychain"

mv .env-template .env

OUT=`xcrun security find-identity -p codesigning -v "${KEYCHAIN}"`
IDENTITY=`echo $OUT | awk -F'"' '{print $2}' | tr -d '\n'`
CODE_SIGN_IDENTITY="${IDENTITY}" make ipa

