//
//  LocationPermissionViewController.m
//  TesselBluetoothDemo
//
//  Created by Rachel Bobbins on 10/5/14.
//  Copyright (c) 2014 Rachel Bobbins. All rights reserved.
//

#import "LocationPermissionViewController.h"
#import "AlertPermissionViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "UIAlertController+Temporary.h"

@interface LocationPermissionViewController () <CLLocationManagerDelegate>

@property (nonatomic) CLLocationManager *locationManager;

- (IBAction)didTapYes:(id)sender;
- (IBAction)didTapNo:(id)sender;

@end

@implementation LocationPermissionViewController


#pragma mark - UIViewController
- (void)viewDidLoad {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
}


#pragma mark - Actions

- (IBAction)didTapYes:(id)sender {
    CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
    if ( authorizationStatus == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestAlwaysAuthorization];
    }
    else {
        UIAlertController *alertController = [UIAlertController notImplementedAlert];
        [self presentViewController:alertController animated:NO completion:nil];
    }
}

- (IBAction)didTapNo:(id)sender {
    [self transitionToNextStep];
}

#pragma mark - <CLLocationManagerDelegate>

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied:
            [self.yesButton setTitle:@"Yes, via device settings" forState:UIControlStateNormal];
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
            [self transitionToNextStep];
            break;
        default:
            break;
    }
}

#pragma mark - Private
- (void)transitionToNextStep {
    AlertPermissionViewController *viewController = [[AlertPermissionViewController alloc] init];
    [self.navigationController pushViewController:viewController
                                         animated:NO];
}

@end
