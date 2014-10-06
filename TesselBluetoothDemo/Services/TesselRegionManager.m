//
//  TesselRegionManager.m
//  TesselBluetoothDemo
//
//  Created by Rachel Bobbins on 10/4/14.
//  Copyright (c) 2014 Rachel Bobbins. All rights reserved.
//

#import "TesselRegionManager.h"
#import <CoreLocation/CoreLocation.h>


static NSString *kRachelsTesselsUUIDString = @"e2c56db5-dffb-48d2-b060-d0f5a71096e0";
static NSString *kRegionIdentifierForRachelsTessel = @"!!";

@implementation TesselRegionManager

- (NSArray *)knownTesselRegions {
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:kRachelsTesselsUUIDString];
    CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                                                                     major:0
                                                                     minor:0
                                                                identifier:kRegionIdentifierForRachelsTessel];
    region.notifyEntryStateOnDisplay = YES;
    region.notifyOnEntry = YES;
    return @[region];
}

@end
