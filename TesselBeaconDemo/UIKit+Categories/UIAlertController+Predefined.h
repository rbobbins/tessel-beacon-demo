//
//  UIAlertController+Predefined.h
//  TesselBeaconDemo
//
//  Created by Rachel Bobbins on 11/25/14.
//  Copyright (c) 2014 Rachel Bobbins. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (Predefined)

+ (instancetype)alertControllerWithOKButtonAndTitle:(NSString *)title message:(NSString *)message;

@end
