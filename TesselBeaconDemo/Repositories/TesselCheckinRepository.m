//
//  TesselCheckinRepository.m
//  TesselBeaconDemo
//
//  Created by Rachel Bobbins on 10/26/14.
//  Copyright (c) 2014 Rachel Bobbins. All rights reserved.
//

#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import "TesselCheckinRepository.h"

@interface TesselCheckinRepository ()
@property (nonatomic, strong) AFHTTPRequestOperationManager *requestOperationmanager;
@end

@implementation TesselCheckinRepository

- (instancetype)initWithRequestOperationManager:(AFHTTPRequestOperationManager *)requestOperationManager {
    self = [super init];
    if (self) {
        self.requestOperationmanager = requestOperationManager;
    }
    return self;
}

- (void)checkinAtTessel:(NSUUID *)uuid {
    NSString *urlString = [NSString stringWithFormat:@"api/tessels/%@/checkins", uuid.UUIDString];
    NSDictionary *parameters = @{@"checkin": @{@"device_id": [[[UIDevice currentDevice] identifierForVendor] UUIDString]}};
    [self.requestOperationmanager POST:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"================> Posted checkin to Tessel!");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"================> Error posting checkin to Tessel: %@", error.localizedDescription);
    }];
}




@end
