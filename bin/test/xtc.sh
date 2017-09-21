#!/usr/bin/env bash

#gem uninstall -Vax --force --no-abort-on-dependent run_loop
#gem uninstall -Vax --force --no-abort-on-dependent calabash-cucumber
#
#(cd ../run-loop && rake install)
#(cd ../calabash-ios/calabash-cucumber && rake install)

#make ipa

cd xtc-submit

rm -rf .xtc
mkdir .xtc
echo 87c0333d165301c018779c35abb418ac9e6ac96d > .xtc/device-agent-sha

# 25 devices
DEVICE_SET=dbf610f6
SERIES="No wait b4 SB alert check"

bundle exec test-cloud submit \
  Permissions.ipa \
  d2e62be879f95a833a63b712cdda5885 \
  --devices $DEVICE_SET \
  --series "${SERIES}" \
  --app-name "Permissions" \
  --user joshua.moody@xamarin.com \
  --dsym-file Permissions.app.dSYM \
  --config cucumber.yml \
  --profile default \
  --include .xtc \
  --test-parameters "pipeline:update-to-DeviceAgent-1.0.5_better_logging"

