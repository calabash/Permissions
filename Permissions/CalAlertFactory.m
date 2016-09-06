#import "CalAlertFactory.h"
#import <sys/utsname.h>

static NSString *const LPDeviceSimKeyModelIdentifier = @"SIMULATOR_MODEL_IDENTIFIER";

@interface CalAlertFactory ()

@property(copy, nonatomic, readonly) NSString *localizedDismiss;

- (UIAlertView *) alertForNYIWithMessage:(NSString *) message;
- (UIAlertView *) alertForNotSupportedWithServiceName:(NSString *) serviceName;


- (NSString *) facebookMessage;
- (NSString *) homeKitMessage;
- (NSString *) healthKitMessage;

@end

@implementation CalAlertFactory

@synthesize localizedDismiss = _localizedDismiss;

- (NSString *) simulatorVersionInfo {
  NSDictionary *env = [[NSProcessInfo processInfo] environment];
  return [env objectForKey:LPDeviceSimKeyModelIdentifier];
}

- (NSString *) physicalDeviceModelIdentifier {
  struct utsname systemInfo;
  uname(&systemInfo);
  return @(systemInfo.machine);
}

- (NSString *) modelIdentifier {
  NSString *model = [self simulatorVersionInfo];
  if (model) {
    return model;
  } else {
    return [self physicalDeviceModelIdentifier];
  }
}

- (id) initWithDelegate:(id<UIAlertViewDelegate>) delegate {
  self = [super init];
  if (self) {
    self.delegate = delegate;
  }
  return self;
}

- (NSString *) localizedDismiss {
  if (_localizedDismiss) { return _localizedDismiss; }

  _localizedDismiss = NSLocalizedString(@"Dismiss",
                                        @"Alert button title: touching dismissing the alert with no consequences");
  return _localizedDismiss;
}

- (NSString *) facebookMessage {
  return NSLocalizedString(@"Testing Facebook permissions has not been implemented.",
                           @"Alert message");
}

- (NSString *) homeKitMessage {
  return NSLocalizedString(@"Testing Home Kit permissions has not been implemented.",
                           @"Alert message");
}

- (NSString *) healthKitMessage {
  return NSLocalizedString(@"Testing Health Kit permissions has not been implemented.",
                           @"Alert message");
}

- (UIAlertView *) alertForNYIWithMessage:(NSString *) message {
  NSString *title = NSLocalizedString(@"Not Implemented",
                                      @"Alert title: feature is not implemented yet");
  UIAlertView *alert = [[UIAlertView alloc]
                        initWithTitle:title
                        message:message
                        delegate:self.delegate
                        cancelButtonTitle:self.localizedDismiss
                        otherButtonTitles:nil];
  return alert;
}

- (UIAlertView *) alertForNotSupportedWithServiceName:(NSString *) serviceName {
  NSString *title = @"Not Supported";

  NSString *version = [[UIDevice currentDevice] systemVersion];
  NSString *model = [self modelIdentifier];
  NSString *message = [NSString stringWithFormat:@"%@ is not supported on iOS %@ and/or this device model: %@.",
                       serviceName, version, model];

  UIAlertView *alert = [[UIAlertView alloc]
                        initWithTitle:title
                        message:message
                        delegate:self.delegate
                        cancelButtonTitle:self.localizedDismiss
                        otherButtonTitles:nil];
  return alert;

}

- (UIAlertView *) alertForFacebookNYI {
  return [self alertForNYIWithMessage:[self facebookMessage]];
}

- (UIAlertView *) alertForHomeKitNYI {
  return [self alertForNYIWithMessage:[self homeKitMessage]];
}

- (UIAlertView *) alertForHealthKitNotSupported {
  return [self alertForNotSupportedWithServiceName:@"HealthKit"];
}

// We have not been able to generate a Bluetooth alert, but we have one example
// in English.
- (UIAlertView *) alertForBluetoothFAKE {
  NSString *title = @"APP NAME would like to make data available to nearby bluetooth devices even when you're not using the app";
  NSString *no = @"Don't Allow";
  NSString *ok = @"OK";

  return [[UIAlertView alloc]
          initWithTitle:title
          message:nil
          delegate:self.delegate
          cancelButtonTitle:no
          otherButtonTitles:ok, nil];
}

- (UIAlertView *) alertForMicrophoneOnSimulatorFAKE {
  NSString *title = @"APP NAME Access the Microphone";
  NSString *no = @"Don't Allow";
  NSString *ok = @"OK";

  return [[UIAlertView alloc]
          initWithTitle:title
          message:nil
          delegate:self.delegate
          cancelButtonTitle:no
          otherButtonTitles:ok, nil];
}

@end
