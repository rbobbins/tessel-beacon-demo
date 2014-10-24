//
//  TesselRegistrationRepository.m
//  TesselBeaconDemo
//
//  Created by Rachel Bobbins on 10/23/14.
//  Copyright (c) 2014 Rachel Bobbins. All rights reserved.
//

#import "TesselRegistrationRepository.h"
#import "KSDeferred.h"
#import <AFNetworking/AFHTTPRequestOperationManager.h>

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
        [deferred resolveWithValue:responseDictionary[@"uuid"]];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [deferred rejectWithError:error];
    }];

    return deferred.promise;
}
@end
