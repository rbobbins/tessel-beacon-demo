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


@interface LocationPermissionViewController () <CLLocationManagerDelegate>

@property (nonatomic) CLLocationManager *locationManager;

- (IBAction)didTapYes:(id)sender;
- (IBAction)didTapNo:(id)sender;

@end

@implementation LocationPermissionViewController


#pragma mark - UIViewController
- (void)viewDidLoad {
    self.title = @"Step 2: Location Permission";
    self.navigationItem.hidesBackButton = YES;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    NSString *baseString = @"iBeacons are part of Apple's CoreLocation framework. In order to detect nearby Tessels, this application needs permisson to monitor your location. Note that NO geographical location is tracked - only a relative location to Tessel devices.\n\n Would you like to enable location monitoring? (Keep in mind that by declining, you'll be unable to use your Tessel as an iBeacon)";
    NSMutableAttributedString *explanatoryText = [[NSMutableAttributedString alloc] initWithString:baseString];
    [explanatoryText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Helvetica-Bold" size:17] range:[baseString rangeOfString:@"NO geographical location is tracked"]];
    self.explanatoryLabel.attributedText = explanatoryText;
}


#pragma mark - Actions

- (IBAction)didTapYes:(id)sender {
    CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
    if ( authorizationStatus == kCLAuthorizationStatusNotDetermined) {
        /*Apple docs on -requestAlwaysAuthorization:
         
         When the current authorization status is kCLAuthorizationStatusNotDetermined, this method runs asynchronously and prompts the user to grant permission to the app to use location services.
         
         The user prompt contains the text from the NSLocationAlwaysUsageDescription key in your app’s Info.plist file, and the presence of that key is required when calling this method. After the status is determined, the location manager delivers the results to the delegate’s locationManager:didChangeAuthorizationStatus: method.
         
         If the current authorization status is anything other than kCLAuthorizationStatusNotDetermined, this method does nothing and does not call the locationManager:didChangeAuthorizationStatus: method.
         */
        [self.locationManager requestAlwaysAuthorization];
    }
}

- (IBAction)didTapNo:(id)sender {
    [self configureWarningLabel];
    [self configureYesButtonAsNextButton];
}

#pragma mark - <CLLocationManagerDelegate>

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied:
        {
            [self configureWarningLabel];
            [self configureYesButtonAsNextButton];
            
            break;
        }
        case kCLAuthorizationStatusAuthorizedAlways:
        {
            self.explanatoryLabel.text = @"You've already given location permission. Please tap 'Next' to continue";
            [self configureYesButtonAsNextButton];
            break;
        }
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

- (void)configureYesButtonAsNextButton {
    self.noButton.hidden = YES;
    [self.yesButton setTitle:@"Next" forState:UIControlStateNormal];
    [self.yesButton removeTarget:nil action:nil forControlEvents:UIControlEventAllEvents];
    [self.yesButton addTarget:self action:@selector(transitionToNextStep) forControlEvents:UIControlEventTouchUpInside];
}

- (void)configureWarningLabel {
    self.explanatoryLabel.text = @"WARNING\n\nYou have not given this application permission to use your device's location services.\n\nPlease go to Settings > Privacy > Location > TesselBeaconDemo and choose the 'Allow Location Access: Always' option.\n\n If you do not do this, the application will not function properly";
}

@end
