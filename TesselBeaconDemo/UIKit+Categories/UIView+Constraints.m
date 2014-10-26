//
//  UIView+Constraints.m
//  TesselBeaconDemo
//
//  Created by Rachel Bobbins on 10/26/14.
//  Copyright (c) 2014 Rachel Bobbins. All rights reserved.
//

#import "UIView+Constraints.h"

@implementation UIView (Constraints)


- (void)addCenterXConstraintToSuperview {
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self
                                                                  attribute:NSLayoutAttributeCenterX
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.superview
                                                                  attribute:NSLayoutAttributeCenterX
                                                                 multiplier:1.0
                                                                   constant:0.f];
    [self.superview addConstraint:constraint];
}

- (void)addCenterYConstraintToSuperview {
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self
                                                                  attribute:NSLayoutAttributeCenterY
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.superview
                                                                  attribute:NSLayoutAttributeCenterY
                                                                 multiplier:1.0
                                                                   constant:0.f];
    [self.superview addConstraint:constraint];
}


@end
