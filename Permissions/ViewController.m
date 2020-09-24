//
//  ViewController.m
//  Permissions
//
//  Created by Villars Gimm on 06/02/14.
//  Copyright (c) 2014 Villars Gimm. All rights reserved.

@import AddressBook;
@import EventKit;
@import AVFoundation;
@import CoreBluetooth;
@import CoreMotion;
@import Accounts;
@import UIKit;
@import MediaPlayer;
@import Speech;

#import "RowDetails.h"
#import "CalAlertFactory.h"
#import <objc/runtime.h>
#import <HealthKit/HealthKit.h>

static NSString *const CalPresentAllAlertsNotification = @"sh.calaba.Permissions";

@interface UIView (CalabashPermissions)

- (BOOL) isHealthKitAvailable;
- (void) sendNotificationToPresentAllAlerts;

@end

@implementation UIView (CalabashPermissions)

// HealthKit is available on iOS > 7 and only on some devices
- (BOOL) isHealthKitAvailable {
  return NSClassFromString(@"HKHealthStore") && [HKHealthStore isHealthDataAvailable];
}

- (void) sendNotificationToPresentAllAlerts {
   [[NSNotificationCenter defaultCenter]
    postNotificationName:CalPresentAllAlertsNotification object:nil];
}

@end

static NSString *const CalCellIdentifier = @"cell identifier";

typedef enum : NSInteger {
  kRowLocationServices = 0,
  kRowBackgroundLocationServices,
  kRowContacts,
  kRowCalendars,
  kRowReminders,
  kRowPhotos,
  kRowBlueTooth,
  kRowMicrophone,
  kRowMotionActivity,
  kRowCamera,
  kFacebook,
  kTwitter,
  kHomeKit,
  kHealthKit,
  kAPNS,
  kAppleMusic,
  kSpeechRecognition,
  kNumberOfRows
} CalTableRows;

#import "ViewController.h"

@interface ViewController ()

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) SFSpeechRecognizer *speechRecognizer;
@property (strong, nonatomic) EKEventStore *eventStore;
@property (strong, nonatomic) UIImagePickerController *picker;
@property (strong, nonatomic) CBCentralManager *cbManager;
@property (strong, nonatomic) CMMotionActivityManager *cmManger;
@property (strong, nonatomic) NSOperationQueue* motionActivityQueue;
@property (strong, nonatomic) ACAccountStore *accountStore;
@property (strong, nonatomic, readonly) CalAlertFactory *alertFactory;
@property (weak, nonatomic) IBOutlet UILabel *actionLabel;

- (ABAddressBookRef) addressBook;
- (void) setAddressBook:(ABAddressBookRef) newAddressBook;

@property (weak, nonatomic) IBOutlet UITableView *table;

- (RowDetails *) detailsForRowAtIndexPath:(NSIndexPath *) path;
- (void) rowTouchedLocationServices;
- (void) rowTouchedBackgroundLocationServices;
- (void) rowTouchedContacts;
- (void) rowTouchedCalendars;
- (void) rowTouchedReminders;
- (void) rowTouchedPhotos;
- (void) rowTouchedBluetooth;
- (void) rowTouchedMicrophone;
- (void) rowTouchedMotionActivity;
- (void) rowTouchedCamera;
- (void) rowTouchedFacebook;
- (void) rowTouchedTwitter;
- (void) rowTouchedHomeKit;
- (void) rowTouchedHealthKit;
- (void) rowTouchedApns;
- (void) rowTouchedAppleMusic;
- (void) rowTouchedSpeechRecognition;

- (void)handleActionLabelTwoFingerTap:(UITapGestureRecognizer *) recognizer;
- (void)handleActionLabelOneFingerTap:(UITapGestureRecognizer *) recognizer;

@end

@implementation ViewController{
  ABAddressBookRef _addressBook;
}

#pragma mark - Memory Management

@synthesize alertFactory = _alertFactory;

- (void) dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (CalAlertFactory *) alertFactory {
  if (_alertFactory) { return _alertFactory; }
  _alertFactory = [[CalAlertFactory alloc]
                   initWithDelegate:self];
  return _alertFactory;
}

#pragma mark - Row Touched: Location Services

- (void) rowTouchedLocationServices {
  NSLog(@"Location Services requested");

  self.locationManager = [[CLLocationManager alloc] init];
  self.locationManager.delegate = self;

  SEL authorizationSelector = @selector(requestWhenInUseAuthorization);
  if ([self.locationManager respondsToSelector:authorizationSelector]) {
    NSLog(@"Requesting when-in-use authorization");
    [self.locationManager requestWhenInUseAuthorization];
  } else {
    if ([CLLocationManager locationServicesEnabled]) {
      NSLog(@"Calling startUpdatingLocation");
      [self.locationManager startUpdatingLocation];
    }
  }
}

- (void) rowTouchedBackgroundLocationServices {
  NSLog(@"Location Services requested");

  self.locationManager = [[CLLocationManager alloc] init];
  self.locationManager.delegate = self;

  NSLog(@"Requesting background location authorization");
  [self.locationManager requestAlwaysAuthorization];
}

#pragma mark - Row Touched: Contacts

- (void) rowTouchedContacts {
  NSLog(@"Contacts requested");
  ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);

  if (addressBook) {
    self.addressBook = CFAutorelease(addressBook);

     // Register for a callback if the addressbook data changes this is
     // important to be notified of new data when the user grants access to the
     // contacts. the application should also be able to handle a nil object
     // being returned as well if the user denies access to the address book.
    ABAddressBookRegisterExternalChangeCallback(self.addressBook,
                                                handleAddressBookChange,
                                                (__bridge void *)(self));

    // When the application requests to receive address book data that is when
    // the user is presented with a consent dialog.
    ABAddressBookRequestAccessWithCompletion(self.addressBook,
                                             ^(bool granted, CFErrorRef error) {
    });
  }
}

#pragma mark - Row Touched: Calendars

- (void) rowTouchedCalendars {
  NSLog(@"Calendar requested");

  self.eventStore = [[EKEventStore alloc] init];

  [self.eventStore requestAccessToEntityType:EKEntityTypeEvent
                                  completion:^(BOOL granted, NSError *error) {
                                  }];
}

- (void) rowTouchedReminders {
  NSLog(@"Reminders requested");

  self.eventStore = [[EKEventStore alloc] init];

  [self.eventStore requestAccessToEntityType:EKEntityTypeReminder
                                  completion:^(BOOL granted, NSError *error) {
                                  }];
}

#pragma mark - Row Touched: Photos

- (void) rowTouchedPhotos {
  NSLog(@"Photos requested");
  UIImagePickerController *picker = [[UIImagePickerController alloc]init];
  [picker setDelegate:self];

  [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - Row Touched: Bluetooth

- (void) rowTouchedBluetooth {
  NSLog(@"Bluetooth Sharing is requested");
  
  [self presentViewController:[self.alertFactory alertForBluetoothFAKE] animated:YES completion:nil];

  /* Have not been able to generate a Bluetooth alert reliably, so we'll
     generate a fake one with the same title.
  if (!self.cbManager) {
    self.cbManager = [[CBCentralManager alloc]
                      initWithDelegate:self
                      queue:dispatch_get_main_queue()
                      options:@{CBCentralManagerOptionShowPowerAlertKey: @(NO)}];
  }

  [self.cbManager scanForPeripheralsWithServices:nil options:nil];
  */
}

#pragma mark - Row Touched: Microphone

- (void) rowTouchedMicrophone {
  NSLog(@"Microphone requested");

#if TARGET_IPHONE_SIMULATOR
  [self presentViewController:[self.alertFactory alertForMicrophoneOnSimulatorFAKE] animated:YES completion:nil];
#else
  [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
    if (granted) {
      NSLog(@"Micro Permission Granted");
      NSError *error;

      if (![[AVAudioSession sharedInstance] setActive:YES error:&error]) {
        NSLog(@"error: %@", [error localizedDescription]);
      }

      if (![[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord
                                                  error:&error]) {
        NSLog(@"error: %@", [error localizedDescription]);
      }

    } else {
      NSLog(@"Permission Denied");
    }
  }];
#endif
}

#pragma mark - Row Touched: Motion Activity

- (void) rowTouchedMotionActivity {
  NSLog(@"Motion Activity requested");
  self.cmManger = [[CMMotionActivityManager alloc]init];
  self.motionActivityQueue = [[NSOperationQueue alloc] init];

  [self.cmManger startActivityUpdatesToQueue:self.motionActivityQueue
                                 withHandler:^(CMMotionActivity *activity) {
  }];
}

#pragma mark - Row Touched: Camera

- (void) rowTouchedCamera {
  if ([AVCaptureDevice respondsToSelector:@selector(requestAccessForMediaType:completionHandler:)]) {
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
      // Will get here on both iOS 7 & 8 even though camera permissions weren't required
      // until iOS 8. So for iOS 7 permission will always be granted.
      if (granted) {
        // Permission has been granted. Use dispatch_async for any UI updating
        // code because this block may be executed in a thread.
        dispatch_async(dispatch_get_main_queue(), ^{

        });
      } else {
        // Permission has been denied.
      }
    }];
  } else {
    // We are on iOS <= 6. Just do what we need to do.
  }
}

#pragma mark - Row Touched: Facebook

- (void) rowTouchedFacebook {
  // not yet
  // http://nsscreencast.com/episodes/57-facebook-integration

  [self presentViewController:[self.alertFactory alertForFacebookNYI] animated:YES completion:nil];

/*
  NSLog(@"Facebook requested");
  if (!self.accountStore) {
    self.accountStore = [[ACAccountStore alloc] init];
  }
  ACAccountType *facebookAccount =
  [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];

  NSDictionary *options = @{
                            ACFacebookAppIdKey:@"697227803740028",
                            ACFacebookPermissionsKey:@[@"read_friendlists"],
                            ACFacebookAudienceKey: ACFacebookAudienceFriends,
                            };

  [self.accountStore
   requestAccessToAccountsWithType:facebookAccount
   options:options completion:^(BOOL granted,
                                NSError *error) {
     if (granted) {
       NSLog(@"Facebook granted!");
       ACAccount *fbAccount = [[self.accountStore
                                accountsWithAccountType:facebookAccount]
                               lastObject];
     } else {
       NSLog(@"Not granted: %@", error);
     }

  }];
  */
}


#pragma mark - Row Touched: Twitter

- (void) rowTouchedTwitter {

  NSLog(@"Twitter Requested");

  if (!self.accountStore) {
    self.accountStore = [[ACAccountStore alloc] init];
  }
  ACAccountType *twitterAccount = [self.accountStore
          accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];

  [self.accountStore requestAccessToAccountsWithType:twitterAccount options:nil
                                          completion:^(BOOL granted, NSError *error) {
  }];
}

#pragma mark - Row Touched: Home Kit

- (void) rowTouchedHomeKit {
  [self presentViewController:[self.alertFactory alertForHomeKitNYI]animated:YES completion:nil];
}

#pragma mark - Row Touched: Health Kit

// http://jademind.com/blog/posts/healthkit-api-tutorial/
- (void) rowTouchedHealthKit {
  if ([[self view] isHealthKitAvailable]) {
    HKHealthStore *healthStore = [[HKHealthStore alloc] init];

    // Share body mass, height and body mass index
    NSSet *shareObjectTypes = [NSSet setWithObjects:
                               [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass],
                               [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight],
                               [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMassIndex],
                               nil];

    // Read date of birth, biological sex and step count
    NSSet *readObjectTypes  = [NSSet setWithObjects:
                               [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth],
                               [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex],
                               [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount],
                               nil];

    // Request access
    [healthStore requestAuthorizationToShareTypes:shareObjectTypes
                                        readTypes:readObjectTypes
                                       completion:^(BOOL success, NSError *error) {
                                         if (success) {
                                           NSLog(@"Successfully enabled HealthKit");
                                         } else {
                                           NSLog(@"Did not enable HealthKit: %@",
                                                 [error localizedDescription]);
                                         }
                                       }];
  } else {
    [self presentViewController:[self.alertFactory alertForHealthKitNotSupported] animated:YES completion:nil];
  }
}

#pragma mark - Row Touched: APNS

- (void) rowTouchedApns {
  UIApplication *shared = [UIApplication sharedApplication];

  UIUserNotificationType types = (UIUserNotificationTypeBadge |
                                  UIUserNotificationTypeSound |
                                  UIUserNotificationTypeAlert);
  UIUserNotificationSettings *settings;
  settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
  [shared registerUserNotificationSettings:settings];
  [shared registerForRemoteNotifications];
}

#pragma mark - Row Touched: Apple Music

- (void) rowTouchedAppleMusic {
  [MPMediaLibrary requestAuthorization:^(MPMediaLibraryAuthorizationStatus status) {}];
}

#pragma mark - Row Touched: Speech Recognition

- (void) rowTouchedSpeechRecognition {
  [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {}];
}

#pragma mark - <UITableViewDataSource>

- (RowDetails *) detailsForRowAtIndexPath:(NSIndexPath *) path {
  RowDetailsFactory *factory = [RowDetailsFactory shared];
  RowDetails *details = [factory detailsForRowAtIndexPath:path];
  if (details) { return details; }

  SEL rowTouchedSelector = nil;
  SEL privacyStatusSelector = nil;
  NSString *title = nil;
  NSString *identifier = nil;

  CalTableRows row = (CalTableRows)path.row;
  switch (row) {
    case kRowLocationServices: {
      rowTouchedSelector = @selector(rowTouchedLocationServices);
      privacyStatusSelector = NSSelectorFromString(@"locationServicesStatus");
      title = @"Location Services";
      identifier = @"location";
      break;
    }

    case kRowBackgroundLocationServices: {
      rowTouchedSelector = @selector(rowTouchedBackgroundLocationServices);
      privacyStatusSelector = NSSelectorFromString(@"backgroundLocationServicesStatus");
      title = @"Background Location Services";
      identifier = @"background location";
      break;
    }

    case kRowContacts: {
      rowTouchedSelector = @selector(rowTouchedContacts);
      privacyStatusSelector = NSSelectorFromString(@"addressBookStatus");
      title = @"Contacts";
      identifier = @"contacts";
      break;
    }

    case kRowCalendars: {
      rowTouchedSelector = @selector(rowTouchedCalendars);
      privacyStatusSelector = NSSelectorFromString(@"calendarStatus");
      title = @"Calendar";
      identifier = @"calendar";
      break;
    }

    case kRowReminders: {
      rowTouchedSelector = @selector(rowTouchedReminders);
      privacyStatusSelector = NSSelectorFromString(@"remindersStatus");
      title = @"Reminders";
      identifier = @"reminders";
      break;
    }

    case kRowPhotos: {
      rowTouchedSelector = @selector(rowTouchedPhotos);
      title = @"Photos";
      identifier = @"photos";
      break;
    }

    case kRowBlueTooth: {
      rowTouchedSelector = @selector(rowTouchedBluetooth);
      title = @"Bluetooth Sharing";
      identifier = @"bluetooth";
      break;
    }

    case kRowMicrophone: {
      rowTouchedSelector = @selector(rowTouchedMicrophone);
      title = @"Microphone";
      identifier = @"microphone";
      break;
    }

    case kRowMotionActivity: {
      rowTouchedSelector = @selector(rowTouchedMotionActivity);
      title = @"Motion Activity";
      identifier = @"motion";
      break;
    }

    case kRowCamera: {
      rowTouchedSelector = @selector(rowTouchedCamera);
      title = @"Camera";
      identifier = @"camera";
      break;
    }

    case kFacebook: {
      rowTouchedSelector = @selector(rowTouchedFacebook);
      title = @"Facebook";
      identifier = @"facebook";
      break;
    }

    case kTwitter: {
      rowTouchedSelector = @selector(rowTouchedTwitter);
      title = @"Twitter";
      identifier = @"twitter";
      break;
    }

    case kHomeKit: {
      rowTouchedSelector = @selector(rowTouchedHomeKit);
      title = @"Home Kit";
      identifier = @"home kit";
      break;
    }

    case kHealthKit: {
      rowTouchedSelector = @selector(rowTouchedHealthKit);
      title = @"Health Kit";
      identifier = @"health kit";
      break;
    }

    case kAPNS: {
      rowTouchedSelector = @selector(rowTouchedApns);
      privacyStatusSelector = NSSelectorFromString(@"apnsStatus");
      title = @"APNS";
      identifier = @"apns";
      break;
    }

    case kAppleMusic: {
      rowTouchedSelector = @selector(rowTouchedAppleMusic);
      title = @"Apple Music";
      identifier = @"apple music";
      break;
    }
      
    case kSpeechRecognition: {
      rowTouchedSelector = @selector(rowTouchedSpeechRecognition);
      title = @"Speech Recognition";
      identifier = @"speech recognition";
      break;
    }

    default: {
      NSString *reason;
      reason = [NSString stringWithFormat:@"Could not create row details for row %@",
                @(row)];
      @throw [NSException exceptionWithName:@"Fell through switch"
                                     reason:reason
                                   userInfo:nil];

      break;
    }
  }

  details = [[RowDetails alloc]
                         initWithRowTouchedSelector:rowTouchedSelector
                              privacyStatusSelector:privacyStatusSelector
                                              title:title
                                         identifier:identifier];
  [[RowDetailsFactory shared] addDetails:details forRowAtIndexPath:path];

  return details;
}

- (NSInteger) tableView:(UITableView *) tableView numberOfRowsInSection:(NSInteger) aSection {
  return kNumberOfRows;
}

- (UITableViewCell *) tableView:(UITableView *) tableView
          cellForRowAtIndexPath:(NSIndexPath *) indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CalCellIdentifier];

  RowDetails *details = [self detailsForRowAtIndexPath:indexPath];
  cell.textLabel.text = details.title;
  cell.accessibilityIdentifier = details.identifier;

  return cell;
}

#pragma mark - <UITableViewDelegate>

- (CGFloat) tableView:(UITableView *) tableView heightForRowAtIndexPath:(NSIndexPath *) indexPath {
  return 44;
}

- (void) tableView:(UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *) indexPath {
  RowDetails *details = [self detailsForRowAtIndexPath:indexPath];
  SEL selector = details.rowTouchedSelector;

  NSMethodSignature *signature;
  signature = [[self class] instanceMethodSignatureForSelector:selector];

  NSInvocation *invocation;
  invocation = [NSInvocation invocationWithMethodSignature:signature];

  invocation.target = self;
  invocation.selector = selector;

  [invocation invoke];
}

#pragma mark - Address Book

- (ABAddressBookRef) addressBook {
  return _addressBook;
}

- (void) setAddressBook:(ABAddressBookRef) newAddressBook {
  if (_addressBook != newAddressBook) {
    if (_addressBook != NULL) {
      CFRelease(_addressBook);
    }
    if (newAddressBook != NULL) {
      CFRetain(newAddressBook);
    }
    _addressBook = newAddressBook;
  }
}

void handleAddressBookChange(ABAddressBookRef addressBook,
                             CFDictionaryRef info,
                             void *context) {

}

#pragma mark - <CBCentralManagerDelegate>

- (void) centralManagerDidUpdateState:(CBCentralManager *)central{
  NSLog(@"Central Bluetooth manager did update state");
  if (central.state != CBCentralManagerStatePoweredOn) { return; }

  if (central.state == CBCentralManagerStatePoweredOn) {
    [self.cbManager scanForPeripheralsWithServices:nil options:nil];
  }
}

#pragma mark - <CLLocationManagerDelegate>

// This method is called whenever the application’s ability to use location
// services changes. Changes can occur because the user allowed or denied the
// use of location services for your application or for the system as a whole.
//
// If the authorization status is already known when you call the
// requestWhenInUseAuthorization or requestAlwaysAuthorization method, the
// location manager does not report the current authorization status to this
// method. The location manager only reports changes to the authorization
// status. For example, it calls this method when the status changes from
// kCLAuthorizationStatusNotDetermined to kCLAuthorizationStatusAuthorizedWhenInUse.
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
  NSLog(@"did change authorization status: %@", @(status));
  CLAuthorizationStatus notDetermined = kCLAuthorizationStatusNotDetermined;
  CLAuthorizationStatus denied = kCLAuthorizationStatusDenied;
  if (status != notDetermined && status != denied) {
    [manager startUpdatingLocation];
  } else {
    NSLog(@"Cannot update location because:");
    if (status == notDetermined) {
      NSLog(@"CoreLocation authorization is not determined");
    } else {
      NSLog(@"CoreLocation authorization is not denied");
    }
  }
}

#pragma mark - <UIAlertViewDelegate>

- (void) alertView:(UIAlertView *) alertView
clickedButtonAtIndex:(NSInteger) buttonIndex {
  NSLog(@"Alert button %@ tapped", @(buttonIndex));
}

#pragma mark - Orientation / Rotation

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000
- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
  return UIInterfaceOrientationMaskAll;
}
#else
- (NSUInteger) supportedInterfaceOrientations {
  return UIInterfaceOrientationMaskAll;
}
#endif

- (BOOL) shouldAutorotate {
  return YES;
}

- (void)handleActionLabelTwoFingerTap:(UITapGestureRecognizer *) recognizer {
  UIGestureRecognizerState state = [recognizer state];
  if (UIGestureRecognizerStateEnded == state) {
      self.actionLabel.text = @"Alert Dismissed";
  }
}

- (void)handleActionLabelOneFingerTap:(UITapGestureRecognizer *) recognizer {
  UIGestureRecognizerState state = [recognizer state];
  if (UIGestureRecognizerStateEnded == state) {
    self.actionLabel.text = @"Ready for Next Alert";
  }
}

- (void)handlePostAllAlertsNotification:(NSNotification *)notification {
  [self rowTouchedLocationServices];
  [self rowTouchedBackgroundLocationServices];
  [self rowTouchedContacts];
  [self rowTouchedCalendars];
  [self rowTouchedReminders];
  [self rowTouchedMotionActivity];
  [self rowTouchedCamera];
  [self rowTouchedTwitter];
  [self rowTouchedApns];
  [self rowTouchedAppleMusic];
  [self rowTouchedSpeechRecognition];
}

#pragma mark - View Lifecycle

- (void) setContentInsets:(UITableView *)tableView {
  CGFloat topHeight = 0;
  if (![[UIApplication sharedApplication] isStatusBarHidden]) {
    CGRect frame = [[UIApplication sharedApplication] statusBarFrame];
    topHeight = topHeight + frame.size.height;
  }
  tableView.contentInset = UIEdgeInsetsMake(topHeight, 0, 0, 0);
}

- (void) viewDidLoad {
  [super viewDidLoad];
  
  self.speechRecognizer.delegate = self;

  [[NSNotificationCenter defaultCenter]
   addObserver:self
   selector:@selector(handlePostAllAlertsNotification:)
   name:CalPresentAllAlertsNotification object:nil];

  self.view.accessibilityIdentifier = @"page";
  [self.table registerClass:[UITableViewCell class]
         forCellReuseIdentifier:CalCellIdentifier];

  UITapGestureRecognizer *oneFingerTapRecognizer;
  oneFingerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                       action:@selector(handleActionLabelOneFingerTap:)];
  oneFingerTapRecognizer.numberOfTapsRequired = 1;
  oneFingerTapRecognizer.numberOfTouchesRequired = 1;

  UITapGestureRecognizer *twoFingerTapRecognizer;
  twoFingerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                       action:@selector(handleActionLabelTwoFingerTap:)];

  twoFingerTapRecognizer.numberOfTapsRequired = 1;
  twoFingerTapRecognizer.numberOfTouchesRequired = 2;

  [self.actionLabel addGestureRecognizer:twoFingerTapRecognizer];
  [self.actionLabel addGestureRecognizer:oneFingerTapRecognizer];

  [twoFingerTapRecognizer requireGestureRecognizerToFail:oneFingerTapRecognizer];

  self.actionLabel.accessibilityIdentifier = @"action label";
}

- (void) viewWillLayoutSubviews {
  [super viewWillLayoutSubviews];
}

- (void) viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
}

@end
