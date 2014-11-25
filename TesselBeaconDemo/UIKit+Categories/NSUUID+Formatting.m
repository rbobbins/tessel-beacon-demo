//
//  NSUUID+Formatting.m
//  TesselBeaconDemo
//
//  Created by Rachel Bobbins on 11/9/14.
//  Copyright (c) 2014 Rachel Bobbins. All rights reserved.
//

#import "NSUUID+Formatting.h"

@implementation NSUUID (Formatting)

- (NSString *)byteArrayString {
    // Via: http://stackoverflow.com/questions/1305225/best-way-to-serialize-a-nsdata-into-an-hexadeximal-string
    
    uuid_t uuidBytes;
    [self getUUIDBytes:uuidBytes];
    
    NSMutableString *hexString  = [NSMutableString string];
    for (int i = 0; i < 16; ++i) {
        [hexString appendString:[NSString stringWithFormat:@"0x%02lx, ", (unsigned long)uuidBytes[i]]];
    }
    
    //chop off the final ", "
    hexString = [[hexString substringToIndex:(hexString.length - 2)] mutableCopy];
    return [NSString stringWithFormat:@"[%@]", hexString];
}

@end
