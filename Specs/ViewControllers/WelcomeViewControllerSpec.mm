#import <Cedar/Cedar.h>
#import "WelcomeViewController.h"
#import "LocationPermissionViewController.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(WelcomeViewControllerSpec)

describe(@"WelcomeViewController", ^{
    __block WelcomeViewController *subject;
    __block UINavigationController *navController;

    beforeEach(^{
        subject = [[WelcomeViewController alloc] init];
        navController = [[UINavigationController alloc] initWithRootViewController:subject];
        subject.view should_not be_nil;
        
    });
    
    it(@"should ask the user whether they'd like to register a Tessel", ^{
        subject.explanatoryLabel.text should equal(@"Would you like to register your own Tessel?");
    });
    
    it(@"should allow the user to choose whether or not they'd like to register a Tessel", ^{
        subject.noButton.titleLabel.text should equal(@"Maybe later");
        subject.yesButton.titleLabel.text should equal(@"Yes!");
    });
    
    describe(@"when the user clicks Yes", ^{
        beforeEach(^{
            [subject.yesButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        });
        
        it(@"should present an alert view re: this feature isn't enabled", ^{
            UIAlertController *alertController = (id)subject.presentedViewController;
            alertController should be_instance_of([UIAlertController class]);
            alertController.message should equal(@"Sorry, not implemented yet");
        });
    });
    
    describe(@"when the user taps No", ^{
        beforeEach(^{
            [subject.noButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        });
        
        it(@"should push a LocationPermissionViewController onto the stack", ^{
            navController.topViewController should be_instance_of([LocationPermissionViewController class]);
        });
    });
});

SPEC_END
