//
//  WelcomeViewController.h
//  TesselBluetoothDemo
//
//  Created by Rachel Bobbins on 10/5/14.
//  Copyright (c) 2014 Rachel Bobbins. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TesselRegistrationRepository;

@interface WelcomeViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *noButton;
@property (weak, nonatomic) IBOutlet UIButton *yesButton;
@property (weak, nonatomic) IBOutlet UILabel *explanatoryLabel;

- (instancetype)init __attribute((unavailable("use designated initializer instead")));
- (instancetype)initWithTesselRegistrationRepository:(TesselRegistrationRepository *)tesselRegistrationRepository;
@end
