#import <Cedar/Cedar.h>
#import "WelcomeViewController.h"
#import "RegistrationViewController.h"
#import "TesselRegistrationRepository.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(WelcomeViewControllerSpec)

describe(@"WelcomeViewController", ^{
    __block WelcomeViewController *subject;
    __block UINavigationController *navController;

    beforeEach(^{
        subject = [[WelcomeViewController alloc] initWithTesselRegistrationRepository:nil];
        navController = [[UINavigationController alloc] initWithRootViewController:subject];
        subject.view should_not be_nil;
    });
    
    it(@"should have the correct title", ^{
        subject.title should equal(@"Step 0: Welcome!");
    });
    
    it(@"should explain the purpose of the app", ^{
        subject.explanatoryLabel.text should contain(@"demonstrates how to use your Tessel device as an iBeacon");
    });
    
    describe(@"when the user taps 'Next'", ^{
        beforeEach(^{
            [subject.navigationItem.rightBarButtonItem.target performSelector:subject.navigationItem.rightBarButtonItem.action withObject:nil];
        });
        
        it(@"should push a RegistrationViewController onto the stack", ^{
            navController.topViewController should be_instance_of([RegistrationViewController class]);
        });
    });
});

SPEC_END
