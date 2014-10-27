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

@end


@interface TesselBeaconManager : NSObject

@property (nonatomic, readonly) CLLocationManager *locationManager;

- (id)init __attribute((unavailable("use with initWithLocationManager:tesselCheckinRepository:tesselRegistrationRepository: instead")));
- (instancetype)initWithLocationManager:(CLLocationManager *)locationManager tesselCheckinRepository:(TesselCheckinRepository *)tesselCheckinRepository tesselRegistrationRepository:(TesselRegistrationRepository *)tesselRegistrationRepository;

- (void)searchForTesselBeacon;
- (void)registerDelegate:(id<TesselBeaconDelegate>)tesselBeaconDelegate;

@end
