//
//  LocationPermissionViewController.h
//  TesselBluetoothDemo
//
//  Created by Rachel Bobbins on 10/5/14.
//  Copyright (c) 2014 Rachel Bobbins. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CLLocationManager;

@interface LocationPermissionViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *yesButton;
@property (weak, nonatomic) IBOutlet UIButton *noButton;
@property (weak, nonatomic) IBOutlet UILabel *explanatoryLabel;
@property (nonatomic, strong, readonly) CLLocationManager *locationManager;

@end
