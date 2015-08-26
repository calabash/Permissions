//
//  ViewController.h
//  Permissions
//
//  Created by Villars Gimm on 06/02/14.
//  Copyright (c) 2014 Villars Gimm. All rights reserved.

@import CoreBluetooth;

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController
<CLLocationManagerDelegate,
UINavigationControllerDelegate,
UIImagePickerControllerDelegate,
CBCentralManagerDelegate,
UITableViewDataSource,
UITableViewDelegate,
UIAlertViewDelegate>

@end
