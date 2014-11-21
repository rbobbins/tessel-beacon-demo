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
@property (nonatomic) TesselRegistrationRepository *tesselRegistrationRepository;

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
        self.locationManager.delegate = self;
    }

    return self;
}

- (BOOL)isMonitoringTesselRegion {
    CLBeaconRegion *region = [self.tesselRegistrationRepository registeredTesselRegion];
    return [self.locationManager.monitoredRegions containsObject:region];
}

- (void)startMonitoringTesselRegion {

    // Check permission, since locationManager:monitoringDidFailForRegion:withError:
    // does not get triggered when monitoring fails due to insufficient permission.
    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted: {
            NSError *error = [[NSError alloc] initWithDomain:kTesselErrorDomain
                                                        code:TesselErrorInsufficientPermission
                                                    userInfo:nil];
            [self.delegate monitoringFailedWithError:error];
            return;
        }
        case kCLAuthorizationStatusNotDetermined: {
            NSError *error = [[NSError alloc] initWithDomain:kTesselErrorDomain code:TesselWarningUndeterminedPermissionUserShouldTryAgain userInfo:nil];
            [self.delegate monitoringFailedWithError:error];
            [self.locationManager requestAlwaysAuthorization];
            return;
        }

        case kCLAuthorizationStatusAuthorizedAlways: {
            CLBeaconRegion *region = [self.tesselRegistrationRepository registeredTesselRegion];
            [self.locationManager startMonitoringForRegion:region];
        }
        default:
            break;
    }
}

- (void)stopMonitoringTesselRegion {
    CLRegion *region = [self.tesselRegistrationRepository registeredTesselRegion];
    [self.locationManager stopMonitoringForRegion:region];
}

- (BOOL)isRangingTesselRegion {
    CLBeaconRegion *region = [self.tesselRegistrationRepository registeredTesselRegion];
    return [self.locationManager.rangedRegions containsObject:region];
}

- (void)startRangingTesselRegion {
    
    // Check permission, since locationManager:monitoringDidFailForRegion:withError:
    // does not get triggered when monitoring fails due to insufficient permission.
    
    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted: {
            NSError *error = [[NSError alloc] initWithDomain:kTesselErrorDomain
                                                        code:TesselErrorInsufficientPermission
                                                    userInfo:nil];
            [self.delegate rangingFailedWithError:error];
            return;
        }
        case kCLAuthorizationStatusNotDetermined: {
            NSError *error = [[NSError alloc] initWithDomain:kTesselErrorDomain
                                                        code:TesselWarningUndeterminedPermissionUserShouldTryAgain
                                                    userInfo:nil];
            [self.delegate rangingFailedWithError:error];
            [self.locationManager requestAlwaysAuthorization];
            return;
        }
            
        case kCLAuthorizationStatusAuthorizedAlways: {
            CLBeaconRegion *region = [self.tesselRegistrationRepository registeredTesselRegion];
            [self.locationManager startRangingBeaconsInRegion:region];
        }
        default:
            break;
    }

}

- (void)stopRangingTesselRegion {
    //This array should never have more than 1 object
    for (CLBeaconRegion *region in self.locationManager.rangedRegions) {
        [self.locationManager stopRangingBeaconsInRegion:region];
        
    }
}

#pragma mark - <CLLocationManagerDelegate> 
#pragma mark Responding to Authorization Changes
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

#pragma mark Responding to Region Events

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = @"Welcome to the Tessel region!";
    notification.alertAction = @"More Details";
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    
    [self.tesselCheckinRepository checkinAtTessel:beaconRegion.proximityUUID];
    [self.delegate didEnterTesselRange];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    [manager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
    [self.delegate didExitTesselRange];
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
    [self.delegate monitoringFailedWithError:error];
}

- (void) locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    NSLog(@"================> %@ : %@", @"did start monitoring for region", region);
}

#pragma mark Responding to Ranging Events

- (void)locationManager:(CLLocationManager *)manager
        didRangeBeacons:(NSArray *)beacons
               inRegion:(CLBeaconRegion *)region {
    
    CLBeacon *beacon = (id)[beacons firstObject];
    [self.delegate rangingSucceededWithProximity:beacon.proximity];
}


- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region
              withError:(NSError *)error {
    
    [self.delegate rangingFailedWithError:error];
}





@end
