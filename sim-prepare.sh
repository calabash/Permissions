#!/usr/bin/env bash

if which rbenv > /dev/null; then
    RBENV_EXEC="rbenv exec"
else
    RBENV_EXEC=
fi

${RBENV_EXEC} bundle install

TARGET_NAME="Permissions-cal"
XC_PROJECT="Permissions.xcodeproj"
XC_SCHEME="${TARGET_NAME}"
CAL_BUILD_CONFIG=Debug
CAL_BUILD_DIR="${PWD}/build"

rm -rf "${TARGET_NAME}.app"
rm -rf "${CAL_BUILD_DIR}"
mkdir -p "${CAL_BUILD_DIR}"

####################### JENKINS KEYCHAIN #######################################

echo "INFO: unlocking the keychain"

if [ "${USER}" = "jenkins" ]; then
    xcrun security unlock-keychain -p "${KEYCHAIN_PASSWORD}" "${KEYCHAIN_PATH}"
    RETVAL=$?
    if [ ${RETVAL} != 0 ]; then
        echo "FAIL: could not unlock the keychain"
        exit ${RETVAL}
    fi
fi

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
    clean build | xcpretty -c

RETVAL=${PIPESTATUS[0]}

if [ ${RETVAL} != 0 ]; then
    echo "FAIL:  could not build"
    exit ${RETVAL}
else
    echo "INFO: successfully built"
fi

# remove any stale targets
rbenv exec bundle exec calabash-ios sim reset

cp -r "${CAL_BUILD_DIR}/Build/Products/${CAL_BUILD_CONFIG}-iphonesimulator/${TARGET_NAME}.app" ./

echo "export APP=${PWD}/${TARGET_NAME}.app"

echo "export APP=${PWD}/${TARGET_NAME}.app" | pbcopy
echo "Copied 'export APP' to the clipboard."
