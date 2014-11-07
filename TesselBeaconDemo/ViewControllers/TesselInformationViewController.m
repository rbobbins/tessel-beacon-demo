//
//  TesselInformationViewController.m
//  TesselBeaconDemo
//
//  Created by Rachel Bobbins on 11/6/14.
//  Copyright (c) 2014 Rachel Bobbins. All rights reserved.
//

#import "TesselInformationViewController.h"
#import "TesselRegistrationRepository.h"
#import <CoreLocation/CoreLocation.h>

@interface TesselInformationViewController ()

@property (nonatomic) TesselRegistrationRepository *tesselRegistrationRepository;
@property (weak, nonatomic) IBOutlet UILabel *tesselIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *codeSnippetLabel;
@property (weak, nonatomic) IBOutlet UIButton *dismissButton;

@end


@implementation TesselInformationViewController


- (instancetype)initWithTesselRegistrationRepository:(TesselRegistrationRepository *)tesselRegistrationRepository {
    self = [super init];
    if (self) {
        self.tesselRegistrationRepository = tesselRegistrationRepository;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CLBeaconRegion *registeredRegion = [[self.tesselRegistrationRepository registeredTesselRegions] firstObject];
    
    if (registeredRegion) {
        self.tesselIdLabel.text = registeredRegion.proximityUUID.UUIDString;
    }
    
}

#pragma mark - Actions
- (IBAction)didTapDismissButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
