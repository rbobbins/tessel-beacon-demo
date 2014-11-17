//
//  TesselBeaconManager.m
//  TesselBeaconDemo
//
//  Created by Rachel Bobbins on 10/4/14.
//  Copyright (c) 2014 Rachel Bobbins. All rights reserved.
//

#import "TesselBeaconManager.h"
#import "TesselCheckinRepository.h"
#import "TesselRegistrationRepository.h"
#import <CoreLocation/CoreLocation.h>


@interface TesselBeaconManager () <CLLocationManagerDelegate>

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) TesselCheckinRepository *tesselCheckinRepository;
@property (nonatomic) NSMutableArray *delegates;

@property (nonatomic, strong) TesselRegistrationRepository *tesselRegistrationRepository;
@end


@implementation TesselBeaconManager

- (instancetype)initWithLocationManager:(CLLocationManager *)locationManager
                tesselCheckinRepository:(TesselCheckinRepository *)tesselCheckinRepository
           tesselRegistrationRepository:(TesselRegistrationRepository *)tesselRegistrationRepository {

    self = [super init];
    if (self) {
        self.locationManager = locationManager;
        self.tesselCheckinRepository = tesselCheckinRepository;
        self.tesselRegistrationRepository = tesselRegistrationRepository;
        self.delegates = [NSMutableArray array];
        self.locationManager.delegate = self;
    }

    return self;
}


- (void)enableTesselBeaconMonitoring {

    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
            return;
        case kCLAuthorizationStatusNotDetermined:
            [self.locationManager requestAlwaysAuthorization];
            return;
        case kCLAuthorizationStatusAuthorizedAlways: {
            CLBeaconRegion *region = [self.tesselRegistrationRepository registeredTesselRegion];
            [self.locationManager startMonitoringForRegion:region];
        }
        default:
            break;
    }
}

#pragma warning - Untested
- (BOOL)isMonitoringProximityToTesselBeacon {
    CLBeaconRegion *region = [self.tesselRegistrationRepository registeredTesselRegion];
    return [self.locationManager.rangedRegions containsObject:region];
}

- (void)monitorProximityToTesselBeacon {
    CLBeaconRegion *region = [self.tesselRegistrationRepository registeredTesselRegion];
    [self.locationManager startRangingBeaconsInRegion:region];
}

- (void)stopMonitoringProximityToTessel {
    //This array should never have more than 1 object
    for (CLBeaconRegion *region in self.locationManager.rangedRegions) {
        [self.locationManager stopRangingBeaconsInRegion:region];
        
    }
}

- (void)registerDelegate:(id<TesselBeaconDelegate>)tesselBeaconDelegate {
    if (![self.delegates containsObject:tesselBeaconDelegate]) {
        [self.delegates addObject:tesselBeaconDelegate];
    }
}

#pragma mark - <CLLocationManagerDelegate> - Responding to Authorization Changes
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {

    switch (status) {
        case kCLAuthorizationStatusAuthorizedAlways:
        {
            CLBeaconRegion *region = [self.tesselRegistrationRepository registeredTesselRegion];
            [self.locationManager startMonitoringForRegion:region];
            return;            
        }
        default:
            break;
    }
}

#pragma mark - <CLLocationManagerDelegate> - Responding to Region Events

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = @"Welcome to the Tessel region!";
    notification.alertAction = @"More Details";
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    
    [self.tesselCheckinRepository checkinAtTessel:beaconRegion.proximityUUID];
    for (id<TesselBeaconDelegate>delegate in self.delegates) {
        [delegate didEnterTesselRange];
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    [manager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
    for (id<TesselBeaconDelegate>delegate in self.delegates) {
        [delegate didExitTesselRange];
    }
}

-(void)locationManager:(CLLocationManager *)manager
     didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    /*
     This function intentionally left blank.
     
     Apple says this method is required. However, we don't really need it, because
     we implement locationManager:didEnterRegion: and locationManager:didExitRegion:
     (What would we do here that we can't do in either of those more specific implementations?)
     
     Apple Docs:

     The location manager calls this method whenever there is a boundary 
     transition for a region. It calls this method in addition to calling 
     the locationManager:didEnterRegion: and locationManager:didExitRegion: methods.
     */
}


- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSLog(@"================> %@", @"monitoring failed");
}

- (void) locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    NSLog(@"================> %@ : %@", @"did start monitoring for region", region);
}

#pragma mark - <CLLocationManagerDelegate> - Responding to Ranging Events

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    CLBeacon *beacon = (id)[beacons firstObject];
    for (id<TesselBeaconDelegate>delegate in self.delegates) {
        [delegate didUpdateProximityToTessel:beacon.proximity];
    }
}


- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error {
    for (id<TesselBeaconDelegate>delegate in self.delegates) {
        [delegate didFailToMonitorProximitityForTesselRegion:region withErrorMessage:error];
    }
    NSLog(@"================> %@", @"ranging beacons did fail for region");
}





@end
