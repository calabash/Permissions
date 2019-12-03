source bin/log.sh

set -e

if [ -z ${1} ]; then
  echo "Usage: ${0} device-set
Examples:
$ bin/appcenter.sh ios13-and-friends
$ SKIP_IPA_BUILD=1 SERIES='Args and env' bin/appcenter.sh daily-deploy-ios
$ SERIES='DeviceAgent 2.0' bin/appcenter.sh tier1
$ TEST_LOCALE=da_DK bin/appcenter.sh hej-screen
If you need to test local changes to run-loop or Calabash on Test Cloud,
use the BUILD_RUN_LOOP and BUILD_CALABASH env variables.
Responds to these env variables:
        SERIES: the Test Cloud series
SKIP_IPA_BUILD: iff 1, then skip re-building the ipa.
                'make test-ipa' will still be called, so changes in the
                features/ directory will be staged and sent to Test Cloud.
BUILD_RUN_LOOP: iff 1, then rebuild run-loop gem before uploading.
BUILD_CALABASH: iff 1, then rebuild Calabash iOS gem before uploading.
   TEST_LOCALE: device locale
"

  exit 64
fi

CREDS=.appcenter-credentials
if [ ! -e "${CREDS}" ]; then
  error "This script requires a ${CREDS} file"
  error "Generating a template now:"
  cat >${CREDS} <<EOF
export APPCENTER_TOKEN=
EOF
  cat ${CREDS}
  error "Update the file with your credentials and run again."
  error "Bye."
  exit 1
fi

source "${CREDS}"

# The uninstall/install dance is required to test changes in
# run-loop and calabash-cucumber in Test Cloud
if [ "${BUILD_RUN_LOOP}" = "1" ]; then
  gem uninstall -Vax --force --no-abort-on-dependent run_loop
  (cd ../run_loop; rake install)
fi

if [ "${BUILD_CALABASH}" = "1" ]; then
  gem uninstall -Vax --force --no-abort-on-dependent calabash-cucumber
  (cd ../calabash-ios/calabash-cucumber; rake install)
fi

PREPARE_XTC_ONLY="${SKIP_IPA_BUILD}" make ipa

if [ "${SERIES}" = "" ]; then
  SERIES=master
fi

if [ "${TEST_LOCALE}" = "" ]; then
  TEST_LOCALE="en_US"
fi

appcenter test run calabash \
  --app-path testcloud-submit/Permissions.ipa \
  --app App-Center-Test-Cloud/Permissions \
  --project-dir testcloud-submit \
  --token $APPCENTER_TOKEN \
  --devices "App-Center-Test-Cloud/${1}" \
  --config-path cucumber.yml \
  --profile default \
  --test-series master \
  --locale "${TEST_LOCALE}" \
  --disable-telemetry
