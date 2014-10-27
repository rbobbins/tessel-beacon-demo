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


#pragma mark - Actions

- (IBAction)didTapYes:(id)sender {
    [self markOnboardingFlowAsComplete];
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
}

- (IBAction)didTapNo:(id)sender {
    [self markOnboardingFlowAsComplete];
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    AFHTTPRequestOperationManager *requestOperationManager = [AFHTTPRequestOperationManager manager];
    TesselCheckinRepository *tesselCheckinRepository = [[TesselCheckinRepository alloc] initWithRequestOperationManager:requestOperationManager];
    TesselRegistrationRepository *tesselRegistrationRepository = [[TesselRegistrationRepository alloc] initWithRequestOperationManager:requestOperationManager];
    TesselBeaconManager *beaconManager = [[TesselBeaconManager alloc] initWithLocationManager:locationManager
                                                                      tesselCheckinRepository:tesselCheckinRepository
                                                                 tesselRegistrationRepository:tesselRegistrationRepository];
    MainViewController *mainViewController = [[MainViewController alloc] initWithBeaconManager:beaconManager];
    [self.navigationController setViewControllers:@[mainViewController] animated:NO];
}

#pragma mark - Private
- (void)markOnboardingFlowAsComplete {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserDidCompleteOnboarding];
}
@end
