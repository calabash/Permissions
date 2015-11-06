#!/usr/bin/env bash

if [ -z "${TRAVIS}" ]; then
  echo "FAIL: only run this script on Travis"
  exit 1
fi

if [ "${TRAVIS_SECURE_ENV_VARS}" != "true" ]; then
  echo "INFO: skipping keychain install; non-maintainer activity"
  exit 0
fi


tree -h calabash.framework

if [ -e calabash.framework/calabash ]; then
  echo "Calabash framework binary does exist"
else
  echo "Calabash framework binary does not exist"
  exit 1
fi

if [ -e /Users/travis/build/calabash/Permissions/calabash.framework/calabash ]; then
  echo "Calabash framework exists at full path"
else
  echo "Calabash framework does not exist at full path"
  exit 1
fi

bin/ci/travis/install-keychain.sh

CODE_SIGN_DIR="${HOME}/.calabash/calabash-codesign"
KEYCHAIN="${CODE_SIGN_DIR}/ios/Calabash.keychain"

mv .env-template .env

OUT=`xcrun security find-identity -p codesigning -v "${KEYCHAIN}"`
echo "out = $OUT"
IDENTITY=`echo $OUT | awk -F'"' '{print $2}' | tr -d '\n'`
echo "identity = ${IDENTITY}"
CODE_SIGN_IDENTITY="${IDENTITY}" make ipa

