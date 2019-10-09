#!/usr/bin/env bash

set -eo pipefail

source bin/log.sh
source bin/ditto.sh
source bin/simctl.sh

set -e

APP="Permissions.app"
DSYM="${APP}.dSYM"
INSTALL_DIR="Products"
BUILD_PRODUCTS_DSYM_APP="Products/app"
BUILD_PRODUCTS_DSYM_IPA="Products/ipa"

zip_with_ditto "${BUILD_PRODUCTS_DSYM_APP}/${DSYM}" "${BUILD_PRODUCTS_DSYM_APP}/Permissions.app.dSYM.zip"
zip_with_ditto "${BUILD_PRODUCTS_DSYM_IPA}/${DSYM}" "${BUILD_PRODUCTS_DSYM_IPA}/Permissions.ipa.dSYM.zip"
zip_with_ditto "${BUILD_PRODUCTS_DSYM_APP}/${APP}" "${BUILD_PRODUCTS_DSYM_APP}/Permissions.app.zip"

# $1 => SOURCE PATH
# $2 => TARGET NAME
function azupload {
  az storage blob upload \
    --container-name test-apps \
    --file "${1}" \
    --name "${2}"
  echo "${1} artifact uploaded with name ${2}"
}

function xcode_version {
  xcrun xcodebuild -version | \
    grep -E "(\d+\.\d+(\.\d+)?)" | cut -f2- -d" " | \
    tr -d "\n"
}

# Pipeline Variables are set through the AzDevOps UI
# See also the ./azdevops-pipeline.yml
if [[ -z "${AZURE_STORAGE_ACCOUNT}" ]]; then
  echo "AZURE_STORAGE_ACCOUNT is required"
  exit 1
fi

if [[ -z "${AZURE_STORAGE_KEY}" ]]; then
  echo "AZURE_STORAGE_KEY is required"
  exit 1
fi

if [[ -z "${AZURE_STORAGE_CONNECTION_STRING}" ]]; then
  echo "AZURE_STORAGE_CONNECTION_STRING is required"
  exit 1
fi

# Evaluate git-sha value
GIT_SHA=$(git rev-parse --verify HEAD | tr -d '\n')

# Evaluate Permissions version (from Info.plist)
VERSION=$(plutil -p ./Products/app/Permissions.app/Info.plist | grep CFBundleShortVersionString | grep -o '"[[:digit:].]*"' | sed 's/"//g')

# Evaluate the Xcode version used to build artifacts
XC_VERSION=$(xcode_version)

az --version

WORKING_DIR="${BUILD_SOURCESDIRECTORY}"

# Upload `Permissions.ipa`
IPA="${WORKING_DIR}/Products/ipa/Permissions.ipa"
IPA_NAME="Permissions-${VERSION}-Xcode-${XC_VERSION}-${GIT_SHA}.ipa"
azupload "${IPA}" "${IPA_NAME}"

# Upload `Permissions.app.dSYM`
IPA="${WORKING_DIR}/Products/ipa/Permissions.ipa.dSYM.zip"
IPA_NAME="Permissions-${VERSION}-Xcode-${XC_VERSION}-${GIT_SHA}.ipa.dSYM"
azupload "${IPA}" "${IPA_NAME}"

# Upload `Permissions.app`
APP="${WORKING_DIR}/Products/app/Permissions.app.zip"
APP_NAME="Permissions-${VERSION}-Xcode-${XC_VERSION}-${GIT_SHA}.app"
azupload "${APP}" "${APP_NAME}"

# Upload `Permissions.app.dSYM`
APP="${WORKING_DIR}/Products/app/Permissions.app.dSYM.zip"
APP_NAME="Permissions-${VERSION}-Xcode-${XC_VERSION}-${GIT_SHA}.app.dSYM"
azupload "${APP}" "${APP_NAME}"
