//
//  MainViewController.m
//  TesselBluetoothDemo
//
//  Created by Rachel Bobbins on 9/30/14.
//  Copyright (c) 2014 Rachel Bobbins. All rights reserved.
//

#import "MainViewController.h"
#import "TesselBeaconManager.h"
#import <CoreLocation/CoreLocation.h>
#import "TesselInformationViewController.h"

static NSString *cellIdentifier = @"cellIdentifier";

@interface MainViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) TesselBeaconManager *beaconManager;
@property (nonatomic) NSMutableArray *briefMessages;
@property (nonatomic) NSMutableArray *completeMessages;
@property (nonatomic) NSDateFormatter *timestampFormatter;

@end

@implementation MainViewController

- (id)initWithBeaconManager:(TesselBeaconManager *)beaconManager {
    self = [super init];
    if (self) {
        self.beaconManager = beaconManager;
        self.beaconManager.delegate = self;
    }
    
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

#if TARGET_IPHONE_SIMULATOR
#ifndef SPECS
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Warning"
                                                                             message:@"You appear to be using a simulator, not a real device. Because the simulator does not have bluetooth, iBeacons will not work properly"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *dismiss = [UIAlertAction actionWithTitle:@"OK"
                                                      style:UIAlertActionStyleCancel
                                                    handler:nil];
    [alertController addAction:dismiss];
    [self presentViewController:alertController animated:NO completion:nil];
#endif
#endif
    
    self.timestampFormatter = [[NSDateFormatter alloc] init];
    self.timestampFormatter.timeStyle = NSDateFormatterMediumStyle;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
    self.briefMessages = [NSMutableArray array];
    self.completeMessages = [NSMutableArray array];
    self.proximitySwitch.on = [self.beaconManager isRangingTesselRegion];
    self.monitoringSwitch.on = [self.beaconManager isMonitoringTesselRegion];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.briefMessages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    cell.textLabel.text = [self briefMessageAtRow:indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:12.f];
    
    return cell;
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                             message:[self completeMessageAtRow:indexPath.row]
                                                                     preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *dismiss = [UIAlertAction actionWithTitle:@"OK"
                                                      style:UIAlertActionStyleCancel
                                                    handler:nil];
    [alertController addAction:dismiss];
    [self presentViewController:alertController animated:NO completion:nil];
}

#pragma mark <TesselBeaconDelegate>

- (void)didEnterTesselRange {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Bonjour!"
                                                                             message:@"You're near a Tessel"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *dismiss = [UIAlertAction actionWithTitle:@"OK"
                                                      style:UIAlertActionStyleCancel
                                                    handler:nil];
    [alertController addAction:dismiss];
    [self presentViewController:alertController animated:NO completion:nil];
    [self updateTableWithBriefMessage:@"entered range of tessel beacon" completeMessage:nil];
}

- (void)didExitTesselRange {
    [self updateTableWithBriefMessage:@"exited range of tessel beacon" completeMessage:nil];
}

- (void)rangingSucceededWithProximity:(CLProximity)proximity {
    NSString *distance;
    switch (proximity) {
        case CLProximityFar:        distance = @"FAR"; break;
        case CLProximityNear:       distance = @"NEAR"; break;
        case CLProximityImmediate:  distance = @"IMMEDIATE"; break;
        case CLProximityUnknown:    distance = @"unknown"; break;
    }
    NSString *message = [NSString stringWithFormat:@"proximity to tessel: %@", distance];
    [self updateTableWithBriefMessage:message completeMessage:nil];
}

- (void)rangingFailedWithError:(NSError *)error {
    self.proximitySwitch.on = NO;
    [self updateTableWithBriefMessage:@"Automatically toggled ranging switch to off" completeMessage:nil];
    [self updateTableWithError:error];
}

- (void)monitoringFailedWithError:(NSError *)error {
    self.monitoringSwitch.on = NO;
    [self updateTableWithBriefMessage:@"Automatically toggled monitoring switch to off" completeMessage:nil];
    [self updateTableWithError:error];
}

#pragma mark - Actions

- (IBAction)didToggleTesselMonitoring:(id)sender {
    if (self.monitoringSwitch.on) {
        [self.beaconManager startMonitoringTesselRegion];
        [self updateTableWithBriefMessage:@"User toggled boundary monitoring ON" completeMessage:nil];
    } else {
        [self.beaconManager stopMonitoringTesselRegion];
        [self updateTableWithBriefMessage:@"User toggled boundary monitoring OFF" completeMessage:nil];
    }
}

- (IBAction)didToggleProximityMonitoring:(id)sender {
    if (self.proximitySwitch.on) {
        [self.beaconManager startRangingTesselRegion];
        [self updateTableWithBriefMessage:@"User toggled proximity monitoring. Will attempt to monitor proximity to tessel beacon" completeMessage:nil];
    } else {
        [self.beaconManager stopRangingTesselRegion];
        [self updateTableWithBriefMessage:@"User toggled proximity monitoring. Will stop monitoring and logging proximity to tessel beacon" completeMessage:nil];
    }

}


- (IBAction)didTapMyTesselButton:(id)sender {
    TesselInformationViewController *viewController = [[TesselInformationViewController alloc] initWithTesselRegistrationRepository:self.beaconManager.tesselRegistrationRepository];
    [self.navigationController pushViewController:viewController animated:NO];
}


#pragma mark - Private

- (NSString *)briefMessageAtRow:(NSInteger)row {
    return self.briefMessages[(self.briefMessages.count - 1) - row];
}

- (NSString *)completeMessageAtRow:(NSInteger)row {
    return self.completeMessages[(self.completeMessages.count - 1) - row];

}

- (void)updateTableWithBriefMessage:(NSString *)briefMessage completeMessage:(NSString *)completeMessage {
    NSString *timestamp = [self.timestampFormatter stringFromDate:[NSDate date]];
    
    [self.completeMessages addObject:[NSString stringWithFormat:@"%@: %@", timestamp, completeMessage?:briefMessage]];
    [self.briefMessages addObject:[NSString stringWithFormat:@"%@: %@", timestamp, briefMessage]];

    [self.tableView reloadData];
}

- (void)updateTableWithError:(NSError *)error {
    NSString *errorTitle;
    NSString *errorExplanation;
    
    if ([error.domain isEqualToString:kCLErrorDomain]) {
        switch ((CLError)error.code) {
            case kCLErrorLocationUnknown:
                errorTitle = @"kCLErrorLocationUnknown";
                errorExplanation = @"The location manager was unable to obtain a location value right now.";
                break;
            case kCLErrorDenied:
                errorTitle = @"kCLErrorDenied";
                errorExplanation = @"Access to the location service was denied by the user.";
                break;
            case kCLErrorNetwork:
                errorTitle = @"kCLErrorNetwork";
                errorExplanation = @"The network was unavailable or a network error occurred.";
                break;
            case kCLErrorHeadingFailure:
                errorTitle = @"kCLErrorHeadingFailure";
                errorExplanation = @"The heading could not be determined.";
                break;
            case kCLErrorRegionMonitoringDenied:
                errorTitle = @"kCLErrorRegionMonitoringDenied";
                errorExplanation = @"Access to the region monitoring service was denied by the user.";
                break;
            case kCLErrorRegionMonitoringFailure:
                errorTitle = @"kCLErrorRegionMonitoringFailure";
                errorExplanation = @"A registered region cannot be monitored. Monitoring can fail if the app has exceeded the maximum number of regions that it can monitor simultaneously. Monitoring can also fail if the region’s radius distance is too large.";
                break;
            case kCLErrorRegionMonitoringSetupDelayed:
                errorTitle = @"kCLErrorRegionMonitoringSetupDelayed";
                errorExplanation = @"Core Location could not initialize the region monitoring feature immediately.";
                break;
            case kCLErrorRegionMonitoringResponseDelayed:
                errorTitle = @"kCLErrorRegionMonitoringResponseDelayed";
                errorExplanation = @"Core Location will deliver events but they may be delayed. Possible keys in the user information dictionary are described in Error User Info Keys.";
                break;
            case kCLErrorGeocodeFoundNoResult:
                errorTitle = @"kCLErrorGeocodeFoundNoResult";
                errorExplanation = @"The geocode request yielded no result.";
                break;
            case kCLErrorGeocodeFoundPartialResult:
                errorTitle = @"kCLErrorGeocodeFoundPartialResult";
                errorExplanation = @"The geocode request yielded a partial result.";
                break;
            case kCLErrorGeocodeCanceled:
                errorTitle = @"kCLErrorGeocodeCanceled";
                errorExplanation = @"The geocode request was canceled.";
                break;
            case kCLErrorDeferredFailed:
                errorTitle = @"kCLErrorDeferredFailed";
                errorExplanation = @"The location manager did not enter deferred mode for an unknown reason. This error can occur if GPS is unavailable, not active, or is temporarily interrupted. If you get this error on a device that has GPS hardware, the solution is to try again.";
                break;
            case kCLErrorDeferredNotUpdatingLocation:
                errorTitle = @"kCLErrorDeferredNotUpdatingLocation";
                errorExplanation = @"The location manager did not enter deferred mode because location updates were already disabled or paused.";
                break;
            case kCLErrorDeferredAccuracyTooLow:
                errorTitle = @"kCLErrorDeferredAccuracyTooLow";
                errorExplanation = @"Deferred mode is not supported for the requested accuracy. The accuracy must be set to kCLLocationAccuracyBest or kCLLocationAccuracyBestForNavigation.";
                break;
            case kCLErrorDeferredDistanceFiltered:
                errorTitle = @"kCLErrorDeferredDistanceFiltered";
                errorExplanation = @"Deferred mode does not support distance filters. Set the distance filter to kCLDistanceFilterNone.";
                break;
            case kCLErrorDeferredCanceled:
                errorTitle = @"kCLErrorDeferredCanceled";
                errorExplanation = @"The request for deferred updates was canceled by your app or by the location manager. This error is returned if you call the disallowDeferredLocationUpdates method or schedule a new deferred update before the previous deferred update request is processed. The location manager may also report this error too. For example, if the app is in the foreground when a new location is determined, the location manager cancels deferred updates and delivers the location data to your app.";
                break;
            case kCLErrorRangingUnavailable:
                errorTitle = @"kCLErrorRangingUnavailable";
                errorExplanation = @"Ranging is disabled. This might happen if the device is in Airplane mode or if Bluetooth or location services are disabled.";
                break;
            case kCLErrorRangingFailure:
                errorTitle = @"kCLErrorRangingFailure";
                errorExplanation = @"A general ranging error occurred.";
                break;
        }
        
        errorExplanation = [NSString stringWithFormat:@"Apple says:\n%@", errorExplanation];
    }
    else if ([error.domain isEqualToString:kTesselErrorDomain]) {
        switch ((TesselErrorDomain)error.code) {
            case TesselErrorInsufficientPermission:
                errorTitle = @"TesselErrorInsufficientPermission";
                errorExplanation = @"Either you've explicitly denied this application permission for location monitoring, or other settings (i.e. parental controls) prevent you from granting permission. Try going to your device's settings, and checking on the location permissions for this application";
                break;
            case TesselWarningUndeterminedPermissionUserShouldTryAgain:
                errorTitle = @"TesselWarningUndeterminedPermissionUserShouldTryAgain";
                errorExplanation = @"This application didn't have location permission when you last tried to do ranging or monitoring. It immediately asked for location permission - if you granted permission, you should be able to try ranging or monitoring again, without any problems";
            default:
                break;
        }
    }
    else {
        errorTitle = [NSString stringWithFormat:@"Error domain: %@", error.domain];
        errorExplanation = [NSString stringWithFormat:@"Error code: %d", error.code];
    }
    
    [self updateTableWithBriefMessage:[NSString stringWithFormat:@"ERROR: %@ (tap for more details)", errorTitle]
                      completeMessage:[NSString stringWithFormat:@"ERROR: %@\n\n\n%@", errorTitle, errorExplanation]];

    
}
@end
