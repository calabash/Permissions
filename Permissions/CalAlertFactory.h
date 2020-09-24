#import <Foundation/Foundation.h>

@interface CalAlertFactory : NSObject

@property(strong, nonatomic) id<UIAlertViewDelegate> delegate;

- (id) initWithDelegate:(id<UIAlertViewDelegate>) delegate;

- (UIAlertController *) alertForFacebookNYI;
- (UIAlertController *) alertForHomeKitNYI;
- (UIAlertController *) alertForHealthKitNotSupported;
- (UIAlertController *) alertForBluetoothFAKE;
- (UIAlertController *) alertForMicrophoneOnSimulatorFAKE;

@end
