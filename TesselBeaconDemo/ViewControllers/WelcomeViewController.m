//
//  WelcomeViewController.m
//  TesselBluetoothDemo
//
//  Created by Rachel Bobbins on 10/5/14.
//  Copyright (c) 2014 Rachel Bobbins. All rights reserved.
//

#import "WelcomeViewController.h"
#import "LocationPermissionViewController.h"
#import "TesselRegistrationRepository.h"
#import "KSPromise.h"

@interface WelcomeViewController ()
- (IBAction)didTapYes:(id)sender;
- (IBAction)didTapNo:(id)sender;

@property (nonatomic) TesselRegistrationRepository *tesselRegistrationRepository;
@end


@implementation WelcomeViewController

- (instancetype)initWithTesselRegistrationRepository:(TesselRegistrationRepository *)tesselRegistrationRepository;
{
    self = [super init];
    if (self) {
        self.tesselRegistrationRepository = tesselRegistrationRepository;
    }
    return self;
}

#pragma mark - Actions

- (IBAction)didTapYes:(id)sender {
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    [self.yesButton addSubview:spinner];
    self.view.userInteractionEnabled = NO;
    
    KSPromise *promise = [self.tesselRegistrationRepository registerNewTessel];
    [promise then:^id(NSString *newTesselId) {
        [spinner removeFromSuperview];
        self.explanatoryLabel.text = [NSString stringWithFormat:@"Good to go! Your Tessel's unique iBeacon id is: %@", newTesselId];
        self.yesButton.hidden = YES;
        [self.noButton setTitle:@"Next Step" forState:UIControlStateNormal];
        self.view.userInteractionEnabled = YES;
        return newTesselId;
    } error:^id(NSError *error) {
        self.explanatoryLabel.text = @"An error has occurred. Would you like to try again?";
        return nil;
    }];
}

- (IBAction)didTapNo:(id)sender {
    LocationPermissionViewController *viewController = [[LocationPermissionViewController alloc] init];
    [self.navigationController pushViewController:viewController
                                         animated:NO];
}

@end
