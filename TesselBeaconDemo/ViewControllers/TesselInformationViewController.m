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
#import <MessageUI/MessageUI.h>

@interface TesselInformationViewController () <MFMailComposeViewControllerDelegate>

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
    
    self.navigationController.navigationBarHidden = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationController.navigationBarHidden = YES;
    
    CLBeaconRegion *registeredRegion = [self.tesselRegistrationRepository registeredTesselRegion] ;
    
    if (registeredRegion) {
        self.tesselIdLabel.text = registeredRegion.proximityUUID.UUIDString;
        NSMutableAttributedString *stepByStepText = [[NSMutableAttributedString alloc] initWithString:@"Your Tessel MUST run the code here: https://github.com/tessel/ble-ble113a/blob/master/examples/ibeacon.js\n\n"];
        
        [stepByStepText appendAttributedString:[self iBeaconInstructions]];
        self.explanatoryText.attributedText = stepByStepText;
    }
    
}

#pragma mark - Actions

- (IBAction)didTapDismissButton:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (IBAction)didTapToCopyToClipboard:(id)sender {
    CLBeaconRegion *registeredRegion = [self.tesselRegistrationRepository registeredTesselRegion];
    NSString *byteArrayString = [NSString stringWithFormat:@"[%@]", [registeredRegion.proximityUUID byteArrayString]];
    [[UIPasteboard generalPasteboard] setValue:byteArrayString forPasteboardType:(NSString *)kUTTypePlainText];
}

- (IBAction)didTapToEmail:(id)sender {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        mailViewController.subject = @"Tessel iBeacon information";
        
        NSString *messageBody = [@"Attached is the iBeacon code snippet!\n\n" stringByAppendingString:[self iBeaconInstructions].string];
        [mailViewController setMessageBody:messageBody isHTML:NO];
        
        NSURL *ibeaconCodeSnippetURL = [[NSBundle mainBundle] URLForResource:@"ibeacon" withExtension:@"js"];
        NSData *codeSnippetData = [NSData dataWithContentsOfURL:ibeaconCodeSnippetURL];
        [mailViewController addAttachmentData:codeSnippetData mimeType:@"text/plain" fileName:@"ibeacon.js"];
        
        [self presentViewController:mailViewController animated:NO completion:nil];
    } else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Uh-oh"
                                                                                 message:@"Unfortunately, your device is not properly configured for email. Try copying your device ID to the clipboard and emailing it to yourself instead"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }]];
        [self presentViewController:alertController animated:NO completion:nil];
    }
    
    
}

#pragma mark - <MFMailComposeViewControllerDelegate>

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:^{
        if (result != MFMailComposeResultSent) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Email Not Sent"
                                                                                     message:@"Due to either device error or user error, your email was not sent. If you're so inclined, try debugging it yourself! Otherwise, copy your device ID to the clipboard and email it directly to yourself"
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }]];
            [self presentViewController:alertController animated:NO completion:nil];
            
        }
        else {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }];

    
}
         
#pragma mark - Private
- (NSAttributedString *)iBeaconInstructions {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"Find the line beginning with:\n"];
                                                   
    NSAttributedString *codeSnippet = [[NSAttributedString alloc] initWithString:@"var airLocate = new Buffer([...]);" attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Menlo" size:12]}];
    
    [attributedString appendAttributedString:codeSnippet];
    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n\nReplace the byte array with your Tessel id, formatted as below: \n\n"]];
    
    CLBeaconRegion *registeredRegion = [self.tesselRegistrationRepository registeredTesselRegion] ;
    NSString *byteArrayString = [NSString stringWithFormat:@"[%@]", [registeredRegion.proximityUUID byteArrayString]];
    NSAttributedString *newCodeSnippet = [[NSAttributedString alloc] initWithString:byteArrayString attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Menlo" size:12]}];
    [attributedString appendAttributedString:newCodeSnippet];
    return attributedString;
}


@end
