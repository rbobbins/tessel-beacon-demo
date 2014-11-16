//
//  TesselRegistrationRepository.h
//  TesselBeaconDemo
//
//  Created by Rachel Bobbins on 10/23/14.
//  Copyright (c) 2014 Rachel Bobbins. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KSPromise;
@class AFHTTPRequestOperationManager;
@class CLBeaconRegion;

@interface TesselRegistrationRepository : NSObject

- (instancetype)init __attribute((unavailable("use designated initalizer instead")));
- (instancetype)initWithRequestOperationManager:(AFHTTPRequestOperationManager *)requestOperationManager;

- (KSPromise *)registerNewTessel;

- (CLBeaconRegion *)registeredTesselRegion;
@end
