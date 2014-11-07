#import <Cedar/Cedar.h>
#import "TesselInformationViewController.h"
#import "TesselRegistrationRepository.h"
#import <CoreLocation/CoreLocation.h>

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
        __block NSString *tesselId;
        
        beforeEach(^{
            NSUUID *uuid = [NSUUID UUID];
            tesselId = [uuid UUIDString];
            CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@""];
            tesselRegistrationRepository stub_method(@selector(registeredTesselRegions)).and_return(@[region]);
            
            subject.view should_not be_nil;
        });
        
        it(@"should tell the user their device ID", ^{
            subject.tesselIdLabel.text should contain(tesselId);
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
