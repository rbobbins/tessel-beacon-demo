//
//  TesselCheckinRepository.h
//  TesselBeaconDemo
//
//  Created by Rachel Bobbins on 10/26/14.
//  Copyright (c) 2014 Rachel Bobbins. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AFHTTPRequestOperationManager;

@interface TesselCheckinRepository : NSObject

- (instancetype)init __attribute((unavailable("use designated initalizer instead")));
- (instancetype)initWithRequestOperationManager:(AFHTTPRequestOperationManager *)requestOperationManager;

- (void)checkinAtTessel:(NSUUID *)uuid;

@end
