//
//  TesselRegistrationRepository.m
//  TesselBeaconDemo
//
//  Created by Rachel Bobbins on 10/23/14.
//  Copyright (c) 2014 Rachel Bobbins. All rights reserved.
//

#import "TesselRegistrationRepository.h"
#import "KSDeferred.h"
#import "NSUserDefaults+Keys.h"
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import <CoreLocation/CoreLocation.h>

@interface TesselRegistrationRepository ()
@property (nonatomic) AFHTTPRequestOperationManager *requestOperationManager;
@end


@implementation TesselRegistrationRepository


- (instancetype)initWithRequestOperationManager:(AFHTTPRequestOperationManager *)requestOperationManager {
    self = [super init];
    if (self) {
        self.requestOperationManager = requestOperationManager;
    }
    return self;
}

- (KSPromise *)registerNewTessel {
    KSDeferred *deferred = [KSDeferred defer];


    [self.requestOperationManager POST:@"api/tessels"
                            parameters:nil
                               success:^(AFHTTPRequestOperation *operation, NSDictionary *responseDictionary) {
        NSString *uuidString = responseDictionary[@"uuid"];
                                   [[NSUserDefaults standardUserDefaults] setValue:uuidString
                                                                            forKey:kRegisteredTesselId];
        [deferred resolveWithValue:uuidString];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"================> %@", error);
        [deferred rejectWithError:error];
    }];

    return deferred.promise;
}

- (CLBeaconRegion *)registeredTesselRegion {
    NSString *uuidString = [[NSUserDefaults standardUserDefaults] stringForKey:kRegisteredTesselId];

    if (uuidString) {
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuidString];
        CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                                                      identifier:@""];
        beaconRegion.notifyEntryStateOnDisplay = YES;
        beaconRegion.notifyOnEntry = YES;
        beaconRegion.notifyOnExit = YES;
        return beaconRegion;
    }
    return nil;


}
@end
