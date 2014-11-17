//
//  MainViewController.h
//  TesselBluetoothDemo
//
//  Created by Rachel Bobbins on 9/30/14.
//  Copyright (c) 2014 Rachel Bobbins. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TesselBeaconManager.h"


@interface MainViewController : UIViewController <TesselBeaconDelegate>

@property (weak, nonatomic) IBOutlet UISwitch *proximitySwitch;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;
@property (weak, readonly) UITableView *tableView;


- (id)init __attribute((unavailable("use with initWithBeaconManager: instead")));
- (id)initWithBeaconManager:(TesselBeaconManager *)beaconManager;

@end
