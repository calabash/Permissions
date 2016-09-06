#import <Foundation/Foundation.h>

@interface CalAlertFactory : NSObject

@property(strong, nonatomic) id<UIAlertViewDelegate> delegate;

- (id) initWithDelegate:(id<UIAlertViewDelegate>) delegate;

- (UIAlertView *) alertForFacebookNYI;
- (UIAlertView *) alertForHomeKitNYI;
- (UIAlertView *) alertForHealthKitNotSupported;
- (UIAlertView *) alertForBluetoothFAKE;
- (UIAlertView *) alertForMicrophoneOnSimulatorFAKE;

@end
