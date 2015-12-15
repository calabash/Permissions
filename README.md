## Permissions

An app for displaying Privacy Alerts for iOS 7 and greater.

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

### TODO

- [ ] Health Kit
- [ ] Home Kit
- [ ] Cannot get a Bluetooth Sharing alert to pop
- [ ] Cannot get a Microphone alert to pop on iOS Simulators
- [ ] Run on XTC - must wait for Calabash 2.0 support on XTC

