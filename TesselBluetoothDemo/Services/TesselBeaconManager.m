//
//  TesselBeaconManager.m
//  TesselBluetoothDemo
//
//  Created by Rachel Bobbins on 10/4/14.
//  Copyright (c) 2014 Rachel Bobbins. All rights reserved.
//

#import "TesselBeaconManager.h"
#import "TesselRegionManager.h"
#import <CoreLocation/CoreLocation.h>


@interface TesselBeaconManager () <CLLocationManagerDelegate>

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) TesselRegionManager *regionManager;
@property (nonatomic) NSMutableArray *delegates;

@end


@implementation TesselBeaconManager

- (instancetype)initWithLocationManager:(CLLocationManager *)locationManager
                    tesselRegionManager:(TesselRegionManager *)tesselRegionManager {
    
    self = [super init];
    if (self) {
        self.locationManager = locationManager;
        self.regionManager = tesselRegionManager;
        self.delegates = [NSMutableArray array];
        self.locationManager.delegate = self;
    }

    return self;
}


- (void)searchForTesselBeacon {
    
    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
            return;
        case kCLAuthorizationStatusNotDetermined:
            [self.locationManager requestAlwaysAuthorization];
            return;
        case kCLAuthorizationStatusAuthorizedAlways:
            [self.locationManager startMonitoringForRegion:self.region];
        default:
            break;
    }
}


- (void)registerDelegate:(id<TesselBeaconDelegate>)tesselBeaconDelegate {
    if (![self.delegates containsObject:tesselBeaconDelegate]) {
        [self.delegates addObject:tesselBeaconDelegate];
    }
}

#pragma mark - <CLLocationManagerDelegate> (Global State)

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    switch (status) {
        case kCLAuthorizationStatusAuthorizedAlways:
            [self.locationManager startMonitoringForRegion:self.region];
            return;
        default:
            break;
    }
}

-(void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{

    if (state == CLRegionStateInside)
    {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.alertBody = @"Welcome to the Tessel region!";
        notification.alertAction = @"More Details";
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
        
        [manager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
        for (id<TesselBeaconDelegate>delegate in self.delegates) {
            [delegate didEnterTesselRange];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    [manager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
    for (id<TesselBeaconDelegate>delegate in self.delegates) {
        [delegate didExitTesselRange];
    }
}

- (void) locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    NSLog(@"================> %@ : %@", @"did start monitoring for region", region);
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSLog(@"================> %@ : %@", @"entered region", region);
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    CLBeacon *beacon = (id)[beacons firstObject];
    for (id<TesselBeaconDelegate>delegate in self.delegates) {
        [delegate didUpdateProximityToTessel:beacon.proximity];
    }
    NSLog(@"================> beacons in range: %@", beacons);
}


- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error {
    NSLog(@"================> %@", @"ranging beacons did fail for region");
}


- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSLog(@"================> %@", @"monitoring failed");
}

#pragma mark - Private

- (CLBeaconRegion *)region {
    NSArray *allRegions = [self.regionManager knownTesselRegions];
    return [allRegions firstObject];
}


@end
