#!/usr/bin/env bash

bundle

TARGET_NAME="Permissions"
XC_PROJECT="Permissions.xcodeproj"
XC_SCHEME="${TARGET_NAME}"

CAL_DISTRO_DIR="${PWD}/build/ipa"
ARCHIVE_BUNDLE="${CAL_DISTRO_DIR}/${TARGET_NAME}.xcarchive"
APP_BUNDLE_PATH="${ARCHIVE_BUNDLE}/Products/Applications/${TARGET_NAME}.app"
CONFIG=Debug
DYSM_PATH="${ARCHIVE_BUNDLE}/dSYMs/${TARGET_NAME}.app.dSYM"

set +o errexit

if [ -z "${CODE_SIGN_IDENTITY}" ]; then
  xcrun xcodebuild archive \
    -SYMROOT="${CAL_DISTRO_DIR}" \
    -derivedDataPath "${CAL_DISTRO_DIR}" \
    -project "${XC_PROJECT}" \
    -scheme "${XC_SCHEME}" \
    -configuration "${CONFIG}" \
    -archivePath "${ARCHIVE_BUNDLE}" \
    ARCHS="armv7 armv7s arm64" \
    VALID_ARCHS="armv7 armv7s arm64" \
    ONLY_ACTIVE_ARCH=NO \
    -sdk iphoneos | bundle exec xcpretty -c
else
  xcrun xcodebuild archive \
    CODE_SIGN_IDENTITY="${CODE_SIGN_IDENTITY}" \
    -SYMROOT="${CAL_DISTRO_DIR}" \
    -derivedDataPath "${CAL_DISTRO_DIR}" \
    -project "${XC_PROJECT}" \
    -scheme "${XC_SCHEME}" \
    -configuration "${CONFIG}" \
    -archivePath "${ARCHIVE_BUNDLE}" \
    ARCHS="armv7 armv7s arm64" \
    VALID_ARCHS="armv7 armv7s arm64" \
    ONLY_ACTIVE_ARCH=NO \
    -sdk iphoneos | bundle exec xcpretty -c
fi

RETVAL=${PIPESTATUS[0]}

set -o errexit

if [ $RETVAL != 0 ]; then
  echo "FAIL:  archive failed"
  exit $RETVAL
fi

set +o errexit

PACKAGE_LOG="${CAL_DISTRO_DIR}/package.log"

INSTALL_DIR=./Calabash-ipa
if [ -d "${INSTALL_DIR}" ]; then
  rm -rf "${INSTALL_DIR}"
fi

mkdir -p "${INSTALL_DIR}"

IPA="${TARGET_NAME}.ipa"
DSYM="${TARGET_NAME}.app.dSYM"

IPA_EXPORT_PATH="${INSTALL_DIR}/${IPA}"

xcrun xcodebuild \
  -exportArchive \
  -exportFormat IPA \
  -exportPath "${IPA_EXPORT_PATH}" \
  -archivePath "${ARCHIVE_BUNDLE}" \
  -exportWithOriginalSigningIdentity > ${PACKAGE_LOG} 2>&1

RETVAL=$?

echo "INFO: Package Application Log: ${PACKAGE_LOG}"

set -o errexit

if [ $RETVAL != 0 ]; then
  echo "FAIL:  export archive failed"
  exit $RETVAL
else
  echo "INFO: installed ${IPA_EXPORT_PATH}"
fi


mv "${DYSM_PATH}" "${INSTALL_DIR}/${DSYM}"
echo "INFO: installed ${INSTALL_DIR}/${DSYM}"

