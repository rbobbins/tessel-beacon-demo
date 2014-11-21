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

static NSString * const kTesselErrorDomain = @"kTesselErrorDomain";
typedef NS_ENUM(NSInteger, TesselErrorDomain) {
    TesselWarningUndeterminedPermissionUserShouldTryAgain,
    TesselErrorInsufficientPermission
};


@protocol TesselBeaconDelegate <NSObject>

@required
- (void)didEnterTesselRange;
- (void)didExitTesselRange;
- (void)monitoringFailedWithError:(NSError *)error;
- (void)rangingSucceededWithProximity:(CLProximity)proximity;
- (void)rangingFailedWithError:(NSError *)error;

@end


@interface TesselBeaconManager : NSObject

@property (nonatomic, weak) id<TesselBeaconDelegate> delegate;
@property (nonatomic, readonly) CLLocationManager *locationManager;
@property (nonatomic, readonly) TesselRegistrationRepository *tesselRegistrationRepository;

- (id)init __attribute((unavailable("use with initWithLocationManager:tesselCheckinRepository:tesselRegistrationRepository: instead")));
- (instancetype)initWithLocationManager:(CLLocationManager *)locationManager
                tesselCheckinRepository:(TesselCheckinRepository *)tesselCheckinRepository
           tesselRegistrationRepository:(TesselRegistrationRepository *)tesselRegistrationRepository;

- (BOOL)isMonitoringTesselRegion;
- (void)startMonitoringTesselRegion;
- (void)stopMonitoringTesselRegion;

- (BOOL)isRangingTesselRegion;
- (void)startRangingTesselRegion;
- (void)stopRangingTesselRegion;

@end
