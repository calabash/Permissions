#import "CalAlertFactory.h"
#import <sys/utsname.h>

static NSString *const LPDeviceSimKeyModelIdentifier = @"SIMULATOR_MODEL_IDENTIFIER";

@interface CalAlertFactory ()

@property(copy, nonatomic, readonly) NSString *localizedDismiss;

- (UIAlertController *) alertForNYIWithMessage:(NSString *) message;
- (UIAlertController *) alertForNotSupportedWithServiceName:(NSString *) serviceName;


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

- (UIAlertController *) alertForNYIWithMessage:(NSString *) message {
  NSString *title = NSLocalizedString(@"Not Implemented",
                                      @"Alert title: feature is not implemented yet");
  UIAlertController *alert = [UIAlertController  alertControllerWithTitle:title
                              message:message
                              preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:self.localizedDismiss
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction *action) {}];
  [alert addAction:cancelButton];
  return alert;
}

- (UIAlertController *) alertForNotSupportedWithServiceName:(NSString *) serviceName {
  NSString *title = @"Not Supported";

  NSString *version = [[UIDevice currentDevice] systemVersion];
  NSString *model = [self modelIdentifier];
  NSString *message = [NSString stringWithFormat:@"%@ is not supported on iOS %@ and/or this device model: %@.",
                       serviceName, version, model];
  UIAlertController *alert = [UIAlertController  alertControllerWithTitle:title
                              message:message
                              preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:self.localizedDismiss
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction *action) {}];
  [alert addAction:cancelButton];

  
  return alert;

}

- (UIAlertController *) alertForFacebookNYI {
  return [self alertForNYIWithMessage:[self facebookMessage]];
}

- (UIAlertController *) alertForHomeKitNYI {
  return [self alertForNYIWithMessage:[self homeKitMessage]];
}

- (UIAlertController *) alertForHealthKitNotSupported {
  return [self alertForNotSupportedWithServiceName:@"HealthKit"];
}

// We have not been able to generate a Bluetooth alert, but we have one example
// in English.
- (UIAlertController *) alertForBluetoothFAKE {
  NSString *title = @"APP NAME would like to make data available to nearby bluetooth devices even when you're not using the app";
  NSString *no = @"Don't Allow";
  NSString *ok = @"OK";
  
  UIAlertController *alert = [UIAlertController  alertControllerWithTitle:title
                              message:nil
                              preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction *noButton = [UIAlertAction actionWithTitle:no
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction *action) {}];
  UIAlertAction *okButton = [UIAlertAction actionWithTitle:ok
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction *action) {}];
  [alert addAction:noButton];
  [alert addAction:okButton];

  return alert;
}

- (UIAlertController *) alertForMicrophoneOnSimulatorFAKE {
  NSString *title = @"APP NAME Access the Microphone";
  NSString *no = @"Don't Allow";
  NSString *ok = @"OK";
  
  UIAlertController *alert = [UIAlertController  alertControllerWithTitle:title
                              message:nil
                              preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction *noButton = [UIAlertAction actionWithTitle:no
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction *action) {}];
  UIAlertAction *okButton = [UIAlertAction actionWithTitle:ok
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction *action) {}];
  [alert addAction:noButton];
  [alert addAction:okButton];

  return alert;
}

@end
