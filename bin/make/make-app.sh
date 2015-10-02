#!/usr/bin/env bash

bundle

TARGET_NAME="Permissions"
XC_PROJECT="Permissions.xcodeproj"
XC_SCHEME="${TARGET_NAME}"
CAL_BUILD_DIR="${PWD}/build"
CAL_BUILD_CONFIG=Debug

rm -rf "${CAL_BUILD_DIR}"
mkdir -p "${CAL_BUILD_DIR}"

set +o errexit

if [ -z "${CODE_SIGN_IDENTITY}" ]; then
  xcrun xcodebuild \
    -SYMROOT="${CAL_BUILD_DIR}" \
    -derivedDataPath "${CAL_BUILD_DIR}" \
    ARCHS="i386 x86_64" \
    VALID_ARCHS="i386 x86_64" \
    ONLY_ACTIVE_ARCH=NO \
    -project "${XC_PROJECT}" \
    -scheme "${TARGET_NAME}" \
    -sdk iphonesimulator \
    -configuration "${CAL_BUILD_CONFIG}" \
    clean build | bundle exec xcpretty -c
else
  xcrun xcodebuild \
    CODE_SIGN_IDENTITY="${CODE_SIGN_IDENTITY}" \
    -SYMROOT="${CAL_BUILD_DIR}" \
    -derivedDataPath "${CAL_BUILD_DIR}" \
    ARCHS="i386 x86_64" \
    VALID_ARCHS="i386 x86_64" \
    ONLY_ACTIVE_ARCH=NO \
    -project "${XC_PROJECT}" \
    -scheme "${TARGET_NAME}" \
    -sdk iphonesimulator \
    -configuration "${CAL_BUILD_CONFIG}" \
    clean build | bundle exec xcpretty -c
fi

RETVAL=${PIPESTATUS[0]}

set -o errexit

if [ $RETVAL != 0 ]; then
  echo "FAIL:  Could not build"
  exit $RETVAL
else
  echo "INFO: Successfully built"
fi

INSTALL_DIR=./Calabash-app
if [ -d "${INSTALL_DIR}" ]; then
  rm -rf "${INSTALL_DIR}"
fi

mkdir -p "${INSTALL_DIR}"

APP=${TARGET_NAME}.app
DSYM=${TARGET_NAME}.app.dSYM

PRODUCT_DIR="${CAL_BUILD_DIR}/Build/Products/${CAL_BUILD_CONFIG}-iphonesimulator"
APP_BUNDLE_PATH="${PRODUCT_DIR}/${APP}"
DSYM_BUNDLE="${PRODUCT_DIR}/${DSYM}"

mv "${APP_BUNDLE_PATH}" "${INSTALL_DIR}/${APP}"
echo "INFO: installed ${INSTALL_DIR}/${APP}"

mv "${DSYM_BUNDLE}" "${INSTALL_DIR}/${DSYM}"
echo "INFO: installed ${INSTALL_DIR}/${DSYM}"

