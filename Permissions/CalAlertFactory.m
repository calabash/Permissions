#import "CalAlertFactory.h"

@interface CalAlertFactory ()

@property(copy, nonatomic, readonly) NSString *localizedDismiss;
- (UIAlertView *) alertForNYIWithMessage:(NSString *) message;

@end

@implementation CalAlertFactory

@synthesize localizedDismiss = _localizedDismiss;

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

- (UIAlertView *) alertForFacebookNYI {
  return [self alertForNYIWithMessage:[self facebookMessage]];
}

- (UIAlertView *) alertForHomeKitNYI {
  return [self alertForNYIWithMessage:[self homeKitMessage]];
}

@end
