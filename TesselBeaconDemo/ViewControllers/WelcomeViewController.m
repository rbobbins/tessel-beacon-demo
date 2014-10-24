//
//  WelcomeViewController.m
//  TesselBluetoothDemo
//
//  Created by Rachel Bobbins on 10/5/14.
//  Copyright (c) 2014 Rachel Bobbins. All rights reserved.
//

#import "WelcomeViewController.h"
#import "LocationPermissionViewController.h"

@interface WelcomeViewController ()
- (IBAction)didTapYes:(id)sender;
- (IBAction)didTapNo:(id)sender;
@end


@implementation WelcomeViewController

#pragma mark - Actions

- (IBAction)didTapYes:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Uh-oh!" message:@"Sorry, not implemented yet" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *dismiss = [UIAlertAction actionWithTitle:@"OK"
                                                      style:UIAlertActionStyleCancel
                                                    handler:nil];
    [alertController addAction:dismiss];
    [self presentViewController:alertController animated:NO completion:nil];
}

- (IBAction)didTapNo:(id)sender {
    LocationPermissionViewController *viewController = [[LocationPermissionViewController alloc] init];
    [self.navigationController pushViewController:viewController
                                         animated:NO];
}

@end
