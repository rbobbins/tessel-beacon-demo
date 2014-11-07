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
#import "UIView+Constraints.h"
#import "TesselInformationViewController.h"

@interface WelcomeViewController ()
- (IBAction)didTapYes:(id)sender;
- (IBAction)didTapToContinue:(id)sender;

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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.yesButton.translatesAutoresizingMaskIntoConstraints = NO;
}

#pragma mark - Actions

- (IBAction)didTapYes:(id)sender {
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.translatesAutoresizingMaskIntoConstraints = NO;
    [spinner startAnimating];
    
    [self.yesButton addSubview:spinner];
    [self.yesButton setTitle:nil forState:UIControlStateNormal];
    [spinner addCenterXConstraintToSuperview];
    [spinner addCenterYConstraintToSuperview];
    

    self.view.userInteractionEnabled = NO;
    KSPromise *promise = [self.tesselRegistrationRepository registerNewTessel];
    [promise then:^id(NSString *newTesselId) {
        [spinner removeFromSuperview];
        
        TesselInformationViewController *tesselInformationViewController = [[TesselInformationViewController alloc] initWithTesselRegistrationRepository:self.tesselRegistrationRepository];
        [self presentViewController:tesselInformationViewController animated:YES completion:^{
            [self didTapToContinue:nil];
        }];
        return nil;
    } error:^id(NSError *error) {
        self.view.userInteractionEnabled = YES;
        self.explanatoryLabel.text = @"An error has occurred. Would you like to try again?";
        [self.yesButton setTitle:@"Yes!" forState:UIControlStateNormal];
        [spinner removeFromSuperview];
        return nil;
    }];
}

- (IBAction)didTapToContinue:(id)sender {
    LocationPermissionViewController *viewController = [[LocationPermissionViewController alloc] init];
    [self.navigationController pushViewController:viewController
                                         animated:NO];
}


@end
