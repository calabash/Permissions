//
//  AppDelegate.m
//  Permissions
//
//  Created by Villars Gimm on 06/02/14.
//  Copyright (c) 2014 Villars Gimm. All rights reserved.

#import "AppDelegate.h"
#import "MBFingerTipWindow.h"
#import "RowDetails.h"
#import <CoreLocation/CoreLocation.h>
@import AddressBook;
@import EventKit;

@interface AppDelegate ()

- (BOOL) isServiceAuthorized:(NSString *)service;
- (BOOL) locationServicesStatus;
- (BOOL) backgroundLocationServicesStatus;
- (BOOL) addressBookStatus;
- (BOOL) calendarStatus;
- (BOOL) remindersStatus;
- (BOOL) apnsStatus;

@end

@implementation AppDelegate

- (UIWindow *)window {
  if (!_window) {
    MBFingerTipWindow *ftWindow = [[MBFingerTipWindow alloc]
                                   initWithFrame:[[UIScreen mainScreen] bounds]];
    ftWindow.alwaysShowTouches = YES;
    _window = ftWindow;
  }
  return _window;
}

- (BOOL) isServiceAuthorized:(NSString *)service {
  RowDetails *details = [[RowDetailsFactory shared] detailsForIdentifier:service];
  if (!details) { return NO; }

  SEL privacyStatusSelector = details.privacyStatusSelector;
  if (!privacyStatusSelector) { return NO; }

  NSMethodSignature *signature;
  signature = [[self class] instanceMethodSignatureForSelector:privacyStatusSelector];

  NSInvocation *invocation;
  invocation = [NSInvocation invocationWithMethodSignature:signature];

  invocation.target = self;
  invocation.selector = privacyStatusSelector;

  [invocation invoke];

  char ref;
  [invocation getReturnValue:(void **) &ref];
  if (ref == (BOOL)1) {
    return YES;
  } else {
    return NO;
  }
}


- (BOOL)locationServicesStatus {
  return [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse;
}

- (BOOL)backgroundLocationServicesStatus {
  return [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways;
}

- (BOOL)addressBookStatus {
  return ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized;
}

- (BOOL)calendarStatus {
  return [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent] ==
  EKAuthorizationStatusAuthorized;
}

- (BOOL)remindersStatus {
  return [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder] ==
  EKAuthorizationStatusAuthorized;
}

- (BOOL) apnsStatus {
  return [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
}

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
  // Sent when the application is about to move from active to
  // inactive state. This can occur for certain types of temporary
  // interruptions (such as an incoming phone call or SMS message)
  // or when the user quits the application and it begins the
  // transition to the background state.  Use this method to pause
  // ongoing tasks, disable timers, and throttle down OpenGL ES
  // frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  // Use this method to release shared resources, save user data,
  // invalidate timers, and store enough application state
  // information to restore your application to its current state in
  // case it is terminated later.  If your application supports
  // background execution, this method is called instead of
  // applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  // Called as part of the transition from the background to the
  // inactive state; here you can undo many of the changes made on
  // entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  // Restart any tasks that were paused (or not yet started) while
  // the application was inactive. If the application was previously
  // in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
  // Called when the application is about to terminate. Save data if
  // appropriate. See also applicationDidEnterBackground:.
}

@end
