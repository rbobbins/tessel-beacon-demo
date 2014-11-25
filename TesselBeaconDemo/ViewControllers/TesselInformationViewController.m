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
        NSMutableAttributedString *stepByStepText = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"Tessel.instructions.introduction", nil)];
        
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
    NSString *byteArrayString = [registeredRegion.proximityUUID byteArrayString];
    [[UIPasteboard generalPasteboard] setValue:byteArrayString forPasteboardType:(NSString *)kUTTypePlainText];
}

- (IBAction)didTapToEmail:(id)sender {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        mailViewController.subject = NSLocalizedString(@"TesselInformation.email.subject", nil);
        [mailViewController setMessageBody:NSLocalizedString(@"TesselInformation.email.body", nil) isHTML:YES];
        [mailViewController addAttachmentData:[self beaconJavascriptAttachment]
                                     mimeType:@"text/plain"
                                     fileName:@"tesselBeacon.js"];
        
        [self presentViewController:mailViewController animated:NO completion:nil];
    } else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error.emailNotConfigured.alertTitle", nil)
                                                                                 message:NSLocalizedString(@"Error.emailNotConfigured.alertMessage", nil)
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK")
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }]];
        [self presentViewController:alertController animated:NO completion:nil];
    }
    
    
}

#pragma mark - <MFMailComposeViewControllerDelegate>

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error {
    
    //Dismiss the email composer from the view hierarchy
    [self dismissViewControllerAnimated:NO completion:nil];
    
    //Display an alert if it wasn't sent. Otherwise, pop back to the root of the nav stack
    if (result != MFMailComposeResultSent) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error.emailFailedToSend.alertTitle" , nil)
                                                                                 message:NSLocalizedString(@"Error.emailFailedToSend.alertMessage", nil)
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK")
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              [self dismissViewControllerAnimated:YES completion:nil];
                                                          }]];
        
        [self presentViewController:alertController animated:NO completion:nil];
    }
    else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
}
         
#pragma mark - Private

- (NSAttributedString *)iBeaconInstructions {
    NSString *byteArrayString = [self.tesselRegistrationRepository.registeredTesselRegion.proximityUUID byteArrayString];
    NSString *plainTextInstructions = [NSString stringWithFormat:NSLocalizedString(@"Tessel.instructions.detailedInstructions - %@ (byteArrayString)", nil), byteArrayString];

    NSDictionary *attributesForCodeSnippet = @{NSFontAttributeName: [UIFont fontWithName:@"Menlo" size:12]};
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:plainTextInstructions];
    [attributedString addAttributes:attributesForCodeSnippet
                              range:[plainTextInstructions rangeOfString:@"var airLocate = new Buffer([...]);"]];
    [attributedString addAttributes:attributesForCodeSnippet
                              range:[plainTextInstructions rangeOfString:byteArrayString]];
    return attributedString;
}

- (NSData *)beaconJavascriptAttachment {
    
    NSURL *ibeaconCodeSnippetURL = [[NSBundle mainBundle] URLForResource:@"tesselBeaconTemplate" withExtension:@"js"];
    NSData *codeSnippetData = [NSData dataWithContentsOfURL:ibeaconCodeSnippetURL];
    NSString *codeSnippet = [[NSString alloc] initWithData:codeSnippetData encoding:NSUTF8StringEncoding];
    NSString *byteArrayString = [self.tesselRegistrationRepository.registeredTesselRegion.proximityUUID byteArrayString];
    codeSnippet = [codeSnippet stringByReplacingOccurrencesOfString:@"PLACEHOLDER" withString:byteArrayString];

    return [codeSnippet dataUsingEncoding:NSUTF8StringEncoding];
}


@end
