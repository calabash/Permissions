#!/usr/bin/env bash

source bin/ditto.sh

set -eo pipefail

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

if [ -e ./.azure-credentials ]; then
  source ./.azure-credentials
fi

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

if [ "${BUILD_SOURCESDIRECTORY}" != "" ]; then
  WORKING_DIR="${BUILD_SOURCESDIRECTORY}"
else
  WORKING_DIR="."
fi

PRODUCT_DIR="${WORKING_DIR}/Products/ipa"
INFO_PLIST="${PRODUCT_DIR}/Permissions.app/Info.plist"

VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" ${INFO_PLIST})

XC_VERSION=$(/usr/libexec/PlistBuddy -c "Print :DTXcode" ${INFO_PLIST})
XC_BUILD=$(/usr/libexec/PlistBuddy -c "Print :DTXcodeBuild" ${INFO_PLIST})

GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [[ "${GIT_BRANCH}" =~ "tag/" ]]; then
  BUILD_ID="Permissions-${VERSION}-Xcode-${XC_VERSION}-${GIT_SHA}"
else
  BUILD_ID="Permissions-${VERSION}-Xcode-${XC_VERSION}-${GIT_SHA}-AdHoc"
fi

# Upload `Permissions.ipa`
IPA="${WORKING_DIR}/Products/ipa/Permissions.ipa"
azupload "${IPA}" "${BUILD_ID}"

# Upload `Permissions.app.dSYM`
IPA="${WORKING_DIR}/Products/ipa/Permissions.ipa.dSYM.zip"
azupload "${IPA}" "${BUILD_ID}"

# Upload `Permissions.app`
APP="${WORKING_DIR}/Products/app/Permissions.app.zip"
azupload "${APP}" "${BUILD_ID}"

# Upload `Permissions.app.dSYM`
APP="${WORKING_DIR}/Products/app/Permissions.app.dSYM.zip"
azupload "${APP}" "${BUILD_ID}"

echo "${BUILD_ID}"