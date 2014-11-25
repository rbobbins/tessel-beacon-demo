#import <Cedar/Cedar.h>
#import "TesselInformationViewController.h"
#import "TesselRegistrationRepository.h"
#import <CoreLocation/CoreLocation.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "NSUUID+Formatting.h"
#import <MessageUI/MessageUI.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(TesselInformationViewControllerSpec)

describe(@"TesselInformationViewController", ^{
    __block TesselInformationViewController *subject;
    __block TesselRegistrationRepository *tesselRegistrationRepository;
    __block UINavigationController *navController;
    __block UIViewController *rootViewController;

    beforeEach(^{
        rootViewController = [[UIViewController alloc] init];
        navController = [[UINavigationController alloc] initWithRootViewController:rootViewController];

        tesselRegistrationRepository = nice_fake_for([TesselRegistrationRepository class]);
        subject = [[TesselInformationViewController alloc] initWithTesselRegistrationRepository:tesselRegistrationRepository];
        [navController pushViewController:subject animated:NO];
    });
    
    context(@"when the user has registered a Tessel", ^{
        __block NSUUID *uuid;
        __block NSString *tesselId;
        
        beforeEach(^{
            uuid = [NSUUID UUID];
            tesselId = [uuid UUIDString];
            CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@""];
            tesselRegistrationRepository stub_method(@selector(registeredTesselRegion)).and_return(region);
            
            subject.view should_not be_nil;
        });
        
        it(@"should tell the user their device ID", ^{
            subject.tesselIdLabel.text should contain(tesselId);
        });
        
        describe(@"tapping the 'Copy to Clipboard' button", ^{
            __block UIPasteboard *fakePasteboard;
            
            beforeEach(^{
                Class pasteboardClass = [UIPasteboard class];
                fakePasteboard = nice_fake_for([UIPasteboard class]);
                spy_on(pasteboardClass);
                pasteboardClass stub_method(@selector(generalPasteboard)).and_return(fakePasteboard);
                [subject.clipboardButton sendActionsForControlEvents:UIControlEventTouchUpInside];
            });
            
            it(@"should copy the UUID to the clipboard in a format that's easy to copy/paste", ^{
                fakePasteboard should have_received(@selector(setValue:forPasteboardType:))
                    .with([uuid byteArrayString], (NSString *)kUTTypePlainText);
            });
        });
        
        describe(@"tapping the 'Email to myself' button", ^{
            __block MFMailComposeViewController *mailViewController;
            context(@"when the user can send email", ^{
                beforeEach(^{
                    spy_on([MFMailComposeViewController class]);
                    [MFMailComposeViewController class] stub_method(@selector(canSendMail)).and_return(YES);
                    [subject.emailButton sendActionsForControlEvents:UIControlEventTouchUpInside];
                    mailViewController = (id)subject.presentedViewController;
                });
                
                it(@"should present a mail view controller", ^{
                    mailViewController should be_instance_of([MFMailComposeViewController class]);
                });
                
                describe(@"after sending the email", ^{
                    beforeEach(^{
                        [mailViewController.mailComposeDelegate mailComposeController:mailViewController didFinishWithResult:MFMailComposeResultSent error:nil];
                    });
                    
                    it(@"should dismiss the mail view controller", ^{
                        subject.presentedViewController should be_nil;
                    });
                });
                
                describe(@"after failing to send the email", ^{
                    beforeEach(^{
                        [mailViewController.mailComposeDelegate mailComposeController:mailViewController didFinishWithResult:MFMailComposeResultFailed error:nil];
                    });
                    
                    it(@"should alert the user", ^{
                        subject.presentedViewController should be_instance_of([UIAlertController class]);
                        
                        UIAlertController *alertController = (id)subject.presentedViewController;
                        alertController.title should contain(@"Email Not Sent");
                        alertController.message should contain(@"your email was not sent.");
                    });
                    
                    it(@"should dismiss the mail view controller", ^{
                        subject.presentedViewController should_not be_same_instance_as(mailViewController);
                    });
                });
            });
            
            context(@"when the user cannot send email", ^{
                beforeEach(^{
                    spy_on([MFMailComposeViewController class]);
                    [MFMailComposeViewController class] stub_method(@selector(canSendMail)).and_return(NO);
                    
                    [subject.emailButton sendActionsForControlEvents:UIControlEventTouchUpInside];
                });
                
                it(@"should present an alert telling them that email is not enabled", ^{
                    subject.presentedViewController should be_instance_of([UIAlertController class]);
                    
                    UIAlertController *alertController = (id)subject.presentedViewController;
                    alertController.message should contain(@"not properly configured for email");
                }); 
            });
        });
        
        describe(@"tapping the dismiss button", ^{
            it(@"should pop back to the root view", ^{
                spy_on(subject);
                [subject.dismissButton sendActionsForControlEvents:UIControlEventTouchUpInside];
                
                navController.topViewController should be_same_instance_as(rootViewController);
            });
        });
    });
});

SPEC_END
