//
//  UIAlertController+Temporary.m
//  TesselBluetoothDemo
//
//  Created by Rachel Bobbins on 10/5/14.
//  Copyright (c) 2014 Rachel Bobbins. All rights reserved.
//

#import "UIAlertController+Temporary.h"

@implementation UIAlertController (Temporary)
+ (instancetype)notImplementedAlert {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Uh-oh" message:@"Not implemented yet" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:action];
    return alertController;
}
@end
