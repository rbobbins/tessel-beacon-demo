//
//  AlertPermissionViewController.m
//  TesselBluetoothDemo
//
//  Created by Rachel Bobbins on 10/5/14.
//  Copyright (c) 2014 Rachel Bobbins. All rights reserved.
//

#import "AlertPermissionViewController.h"
#import "MainViewController.h"
#import "TesselBeaconManager.h"
#import "NSUserDefaults+Keys.h"
#import "TesselCheckinRepository.h"
#import "TesselRegistrationRepository.h"
#import <CoreLocation/CoreLocation.h>
#import <AFNetworking/AFHTTPRequestOperationManager.h>

@interface AlertPermissionViewController ()
- (IBAction)didTapYes:(id)sender;
- (IBAction)didTapNo:(id)sender;

@end

@implementation AlertPermissionViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Step 2: Notification Permission";
    self.navigationItem.hidesBackButton = YES;
    self.edgesForExtendedLayout = UIRectEdgeNone;
}

#pragma mark - Actions

- (IBAction)didTapYes:(id)sender {
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
}

- (IBAction)didTapNo:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
