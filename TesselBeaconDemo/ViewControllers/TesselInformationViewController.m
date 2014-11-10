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
#import <MobileCoreServices/UTCoreTypes.h>
#import "NSUUID+Formatting.h"

@interface TesselInformationViewController ()

@property (nonatomic) TesselRegistrationRepository *tesselRegistrationRepository;
@property (weak, nonatomic) IBOutlet UILabel *tesselIdLabel;
@property (weak, nonatomic) IBOutlet UIButton *dismissButton;
@property (weak, nonatomic) IBOutlet UIButton *clipboardButton;
@property (weak, nonatomic) IBOutlet UITextView *explanatoryText;

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
        NSMutableAttributedString *stepByStepText = [[NSMutableAttributedString alloc] initWithString:@"Your Tessel MUST run the code here: https://github.com/tessel/ble-ble113a/blob/master/examples/ibeacon.js\n\nFind the line beginning with:\n"];
        
        NSAttributedString *codeSnippet = [[NSAttributedString alloc] initWithString:@"var airLocate = new Buffer([...]);" attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Menlo" size:12]}];
        
        [stepByStepText appendAttributedString:codeSnippet];
        [stepByStepText appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n\nReplace the byte array with your Tessel id, formatted as below: \n\n"]];
        
        NSString *byteArrayString = [NSString stringWithFormat:@"[%@]", [registeredRegion.proximityUUID byteArrayString]];
        NSAttributedString *newCodeSnippet = [[NSAttributedString alloc] initWithString:byteArrayString attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Menlo" size:12]}];
        [stepByStepText appendAttributedString:newCodeSnippet];
        self.explanatoryText.attributedText = stepByStepText;
    }
    
}

#pragma mark - Actions
- (IBAction)didTapDismissButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didTapToCopyToClipboard:(id)sender {
    CLBeaconRegion *registeredRegion = [[self.tesselRegistrationRepository registeredTesselRegions] firstObject];
    NSString *byteArrayString = [NSString stringWithFormat:@"[%@]", [registeredRegion.proximityUUID byteArrayString]];
    [[UIPasteboard generalPasteboard] setValue:byteArrayString forPasteboardType:(NSString *)kUTTypePlainText];
}


@end
