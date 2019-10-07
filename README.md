[![Build Status](https://msmobilecenter.visualstudio.com/Mobile-Center/_apis/build/status/test-cloud/xamarin-uitest/calabash.Permissions?branchName=master)](https://msmobilecenter.visualstudio.com/Mobile-Center/_build/latest?definitionId=3621&branchName=master)
## Permissions

An app for displaying Privacy Alerts for iOS 8 and greater.

### Build

For simplicity, the Permissions target is linked with Calabash when the app is
built with the **Debug** configuration.

```
1. $ git clone git@github.com:calabash/Permissions.git
2. $ cd Permissions
3. $ bundle install
4. $ make app       # Products/app/Permissions.app
5. $ make ipa       # Products/ipa/Permissions.ipa
```

### Testing

```
$ be cucumber
```

### Console

```
# Don't use the calabash-ios console
$ be irb
```

### Use Permissions to Add New Localization

You must use bundler's ability to run from local sources.

```
$ cd ~/git/calabash
$ git clone < run loop >
$ bundle config local.run_loop ~/git/calabash/run_loop
```

In this repo's Gemfile, you will see:

```
gem "run_loop", :github => "calabash/run_loop", :branch => "develop"
```

When running in the context of bundle exec, bundler will use local
sources for run\_loop.

Open ~/git/calabash/run\_loop/scripts/lib/on\_alert.js.

Uncomment these two lines:

```
  var buttonNames = findAlertButtonNames(alert);
  Log.output({"output":"alert: " + title + "," + buttonNames}, true);
```

and save.

Find the two letter language and locale codes.  We'll use French as our
example.

```
$ bundle update
$ APP_LANG=fr APP_LOCALE=fr bundle exec cucumber -t ~@motion
```

Tests will fail, but a file will be generated in ~/tmp/ that contains
lines like this:

```
# Alert title, left button title, right button title
{"output":{"output":"alert: « Permissions » souhaite accéder à vos photos.,Refuser,OK"},"last_index":0}
```

Extract the alert title and accept button title and add them to
scripts/lib/on\_alert.js.

The motion tests need to be run separately because the alert is
completely blocking.

```
$ APP_LANG=fr APP_LOCALE=fr bundle exec cucumber -t @motion
```

The alert title and button tiles will be printed to stdout.  Because
this alert is 100% blocking, no file will be written.

### TODO

- [ ] Facebook
- [ ] Home Kit
- [ ] Cannot get a Bluetooth Sharing alert to pop
- [ ] Cannot get a Microphone alert to pop on iOS Simulators

