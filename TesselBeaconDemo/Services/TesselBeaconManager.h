//
//  TesselBeaconManager.h
//  TesselBeaconDemo
//
//  Created by Rachel Bobbins on 10/4/14.
//  Copyright (c) 2014 Rachel Bobbins. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class CLLocationManager;
@class TesselCheckinRepository;
@class TesselRegistrationRepository;


@protocol TesselBeaconDelegate <NSObject>
@required
- (void)didEnterTesselRange;
- (void)didExitTesselRange;
- (void)didUpdateProximityToTessel:(CLProximity)proximity;

#pragma TODO: Rename; make more generic
- (void)didFailToMonitorProximitityForTesselRegion:(CLRegion *)region
                                  withErrorMessage:(NSError *)error;
@end


@interface TesselBeaconManager : NSObject

@property (nonatomic, readonly) CLLocationManager *locationManager;

- (id)init __attribute((unavailable("use with initWithLocationManager:tesselCheckinRepository:tesselRegistrationRepository: instead")));
- (instancetype)initWithLocationManager:(CLLocationManager *)locationManager tesselCheckinRepository:(TesselCheckinRepository *)tesselCheckinRepository tesselRegistrationRepository:(TesselRegistrationRepository *)tesselRegistrationRepository;

- (BOOL)monitoringEnabled;
- (void)enableTesselBeaconMonitoring;
- (void)stopTesselBeaconMonitoring;

- (BOOL)rangingEnabled;
- (void)monitorProximityToTesselBeacon;
- (void)stopMonitoringProximityToTessel;

#pragma TODO: Singularize
- (void)registerDelegate:(id<TesselBeaconDelegate>)tesselBeaconDelegate;

@end
