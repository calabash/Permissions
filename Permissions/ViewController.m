//
//  ViewController.m
//  Permissions
//
//  Created by Villars Gimm on 06/02/14.
//  Copyright (c) 2014 Villars Gimm. All rights reserved.
//

@import AddressBook;
@import EventKit;
@import AVFoundation;
@import CoreBluetooth;
@import CoreMotion;


#import "ViewController.h"

@interface ViewController ()

//iOS permissions
@property (nonatomic, strong)CLLocationManager *locationManager;
@property (nonatomic, strong)EKEventStore *eventStore;
@property (nonatomic, strong)UIImagePickerController *picker;
@property (nonatomic, strong)CBCentralManager *cbManager;
@property (nonatomic, strong)CMMotionActivityManager *cmManger;
@property (nonatomic, strong)NSOperationQueue* motionActivityQueue;

- (ABAddressBookRef)addressBook;
- (void)setAddressBook:(ABAddressBookRef)newAddressBook;

@end

@implementation ViewController{
    ABAddressBookRef _addressBook;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    NSLog(@"CL Delegate");
}

void handleAddressBookChange(ABAddressBookRef addressBook, CFDictionaryRef info, void *context) {
    /*
     Do something with changed addres book data...
     */
}

- (IBAction)buttonClick:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSString *buttonTitle = button.currentTitle;
    
    if ([buttonTitle isEqualToString:@"Location Services"]) {
        
        NSLog(@"Location Services clicked");
        
        // CLLocationManager *locationManager;
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        
        [self.locationManager startUpdatingLocation];
    }
    else if ([buttonTitle isEqualToString:@"Contacts"]){
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        
        if(addressBook) {
            self.addressBook = CFAutorelease(addressBook);
            /*
             Register for a callback if the addressbook data changes this is important to be notified of new data when the user grants access to the contacts. the application should also be able to handle a nil object being returned as well if the user denies access to the address book.
             */
            ABAddressBookRegisterExternalChangeCallback(self.addressBook, handleAddressBookChange, (__bridge void *)(self));
            
            /*
             When the application requests to receive address book data that is when the user is presented with a consent dialog.
             */
            ABAddressBookRequestAccessWithCompletion(self.addressBook, ^(bool granted, CFErrorRef error) {
                /*dispatch_async(dispatch_get_main_queue(), ^{
                 [self alertViewWithDataClass:Contacts status:(granted) ? NSLocalizedString(@"GRANTED", @"") : NSLocalizedString(@"DENIED", @"")];
                 });*/
            });
        }
    }
    else if ([buttonTitle isEqualToString:@"Calendars"]){
        
        NSLog(@"Calendar is called");
        
        self.eventStore = [[EKEventStore alloc] init];
        
        [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {}];
        
    }
    else if ([buttonTitle isEqualToString:@"Reminders"]){
        
        self.eventStore = [[EKEventStore alloc] init];
        
        [self.eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error) {}];
    }
    else if ([buttonTitle isEqualToString:@"Photos"]){
        NSLog(@"Photos requested");
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        picker.delegate = self;
        //[picker setDelegate:self];
        
        [self presentViewController:picker animated:YES completion:nil];
    }
    else if ([buttonTitle isEqualToString:@"Bluetooth Sharing"]){
        NSLog(@"Bluetooth Sharing");
        if(!self.cbManager) {
            self.cbManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        }
        
        /*
         When the application requests to start scanning for bluetooth devices that is when the user is presented with a consent dialog.
         */
        [self.cbManager scanForPeripheralsWithServices:nil options:nil];
    }
    else if ([buttonTitle isEqualToString:@"Microphone"]){
        NSLog(@"Microphone");
        //requestRecordPermission:
        AVAudioSession *session = [[AVAudioSession alloc] init];
        [session requestRecordPermission:^(BOOL granted) {
            if (granted) {
                NSLog(@"Micro Permission Granted");
                
                NSError *error;
                
                // [session setActive:YES error:&error];
                
                [session setCategory:@"AVAudioSessionCategoryPlayAndRecord" error:&error];
                
            }
            else {
                
                NSLog(@"Permission Denied");
            }
        }];
    }
    else if ([buttonTitle isEqualToString:@"Motion Activity"]){
        NSLog(@"Motion Acitivty");
        self.cmManger = [[CMMotionActivityManager alloc]init];
        self.motionActivityQueue = [[NSOperationQueue alloc] init];
        
        [self.cmManger startActivityUpdatesToQueue:self.motionActivityQueue withHandler:^(CMMotionActivity *activity) {
        }];
    }
}

- (ABAddressBookRef)addressBook {
    return _addressBook;
}

- (void)setAddressBook:(ABAddressBookRef)newAddressBook {
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

- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    
}

@end
