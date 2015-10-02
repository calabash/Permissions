#!/usr/bin/env bash

# Stages binaries built by Xcode to ./Products/

function info {
  echo "INFO: $1"
}

function error {
  echo "$ERROR: $1"
}

function banner {
  echo ""
  echo "######## $1 #######"
  echo ""
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

# Command line builds already stage binaries to Products/
if [ ! -z $COMMAND_LINE_BUILD ]; then
  exit 0
fi

if [ ${CONFIGURATION} != "Debug" ]; then
  info "Skipping staging to Products; only necessary for Debug configuration"
  info "Nothing to do; exiting 0."
  exit 0
fi

if [ ${EFFECTIVE_PLATFORM_NAME} = "-iphoneos" ]; then
  info "Building from Xcode; will stage binary to Products/ipa"
  APP_TARGET_DIR=${SOURCE_ROOT}/Products/ipa
else
  info "Building from Xcode; will stage binary to Products/app"
  APP_TARGET_DIR=${SOURCE_ROOT}/Products/app
fi

rm -rf "${APP_TARGET_DIR}"
mkdir -p "${APP_TARGET_DIR}"

# Copy the .app to staging directory.
APP_SOURCE_PATH="${CONFIGURATION_BUILD_DIR}/${FULL_PRODUCT_NAME}"
APP_TARGET_PATH="${APP_TARGET_DIR}/${FULL_PRODUCT_NAME}"
ditto_or_exit "${APP_SOURCE_PATH}" "${APP_TARGET_PATH}"

# Copy the .dSYM to the staging directory.
DSYM_SOURCE_PATH="${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}"
DSYM_TARGET_PATH="${APP_TARGET_DIR}/${DWARF_DSYM_FILE_NAME}"
ditto_or_exit "${DSYM_SOURCE_PATH}" "${DSYM_TARGET_PATH}"

# For physical devices, package the .ipa
if [ ${EFFECTIVE_PLATFORM_NAME} = "-iphoneos" ]; then
  IPA_PATH="${APP_TARGET_DIR}/${TARGET_NAME}.ipa"
  echo "Zipping .app to ${IPA_PATH}"
  xcrun ditto -ck --rsrc --sequesterRsrc --keepParent \
    "${APP_TARGET_PATH}" \
    "${IPA_PATH}"
fi

