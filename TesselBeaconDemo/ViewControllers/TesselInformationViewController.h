//
//  TesselInformationViewController.h
//  TesselBeaconDemo
//
//  Created by Rachel Bobbins on 11/6/14.
//  Copyright (c) 2014 Rachel Bobbins. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TesselRegistrationRepository;

@interface TesselInformationViewController : UIViewController
- (instancetype)init __attribute((unavailable("use designated initalizer instead")));
- (instancetype)initWithTesselRegistrationRepository:(TesselRegistrationRepository *)tesselRegistrationRepository;

@property (weak, nonatomic, readonly) UILabel *tesselIdLabel;
@property (weak, nonatomic, readonly) UIButton *dismissButton;

@end
