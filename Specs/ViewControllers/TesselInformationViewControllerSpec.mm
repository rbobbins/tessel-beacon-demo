#import <Cedar/Cedar.h>
#import "TesselInformationViewController.h"
#import "TesselRegistrationRepository.h"
#import <CoreLocation/CoreLocation.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "NSUUID+Formatting.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(TesselInformationViewControllerSpec)

describe(@"TesselInformationViewController", ^{
    __block TesselInformationViewController *subject;
    __block TesselRegistrationRepository *tesselRegistrationRepository;

    beforeEach(^{
        tesselRegistrationRepository = nice_fake_for([TesselRegistrationRepository class]);
        subject = [[TesselInformationViewController alloc] initWithTesselRegistrationRepository:tesselRegistrationRepository];
    });
    
    context(@"when the user has registered a Tessel", ^{
        __block NSUUID *uuid;
        __block NSString *tesselId;
        
        beforeEach(^{
            uuid = [NSUUID UUID];
            tesselId = [uuid UUIDString];
            CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@""];
            tesselRegistrationRepository stub_method(@selector(registeredTesselRegions)).and_return(@[region]);
            
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
                NSString *expectedPasteBuffer = [NSString stringWithFormat:@"[%@]", [uuid byteArrayString]];
                fakePasteboard should have_received(@selector(setValue:forPasteboardType:))
                    .with(expectedPasteBuffer, (NSString *)kUTTypePlainText);
            });
        });
        
        describe(@"tapping the okay button", ^{
            it(@"should dismiss itself", ^{
                spy_on(subject);
                [subject.dismissButton sendActionsForControlEvents:UIControlEventTouchUpInside];
                
                subject should have_received(@selector(dismissViewControllerAnimated:completion:)).with(YES, nil);
            });
        });
    });
});

SPEC_END
