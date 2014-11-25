//
//  UIAlertController+Predefined.m
//  TesselBeaconDemo
//
//  Created by Rachel Bobbins on 11/25/14.
//  Copyright (c) 2014 Rachel Bobbins. All rights reserved.
//

#import "UIAlertController+Predefined.h"

@implementation UIAlertController (Predefined)

+ (instancetype)alertControllerWithOKButtonAndTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *dismiss = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                      style:UIAlertActionStyleCancel
                                                    handler:nil];
    [alertController addAction:dismiss];
    return alertController;
}

@end
