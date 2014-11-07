#import <Cedar/Cedar.h>
#import "WelcomeViewController.h"
#import "LocationPermissionViewController.h"
#import "TesselRegistrationRepository.h"
#import "KSDeferred.h"
#import "TesselInformationViewController.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(WelcomeViewControllerSpec)

describe(@"WelcomeViewController", ^{
    __block WelcomeViewController *subject;
    __block UINavigationController *navController;
    __block TesselRegistrationRepository *registrationRepository;

    beforeEach(^{
        registrationRepository = nice_fake_for([TesselRegistrationRepository class]);
        subject = [[WelcomeViewController alloc] initWithTesselRegistrationRepository:registrationRepository];
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
        __block KSDeferred *deferred;
        __block UIActivityIndicatorView *spinner;
        
        beforeEach(^{
            deferred = [KSDeferred defer];
            registrationRepository stub_method(@selector(registerNewTessel)).and_return(deferred.promise);
            [subject.yesButton sendActionsForControlEvents:UIControlEventTouchUpInside];
            spinner = subject.yesButton.subviews.lastObject;
        });
        
        it(@"should send a request to register a Tessel", ^{
            registrationRepository should have_received(@selector(registerNewTessel));
        });

        it(@"should display a spinner", ^{
            spinner should be_instance_of([UIActivityIndicatorView class]);
            spinner.isAnimating should be_truthy;
        });
        
        it(@"should disable all interaction", ^{
            subject.view.userInteractionEnabled should_not be_truthy;
        });
        
        describe(@"after the request succeeds", ^{
            __block NSString *tesselId;
            
            beforeEach(^{
                tesselId = @"unique-identifier";
                [deferred resolveWithValue:tesselId];
            });
            
            it(@"should present a TesselInformationViewController", ^{
                subject.presentedViewController should be_instance_of([TesselInformationViewController class]);
            });
            
            it(@"should jump to the next step of the process when the TesselInformationViewController is dismissed ", ^{
                [subject dismissViewControllerAnimated:NO completion:nil];
                navController.topViewController should be_instance_of([LocationPermissionViewController class]);
            });
        });
        
        describe(@"after the request fails", ^{
            beforeEach(^{
                [deferred rejectWithError:nil];
            });
            
            it(@"should tell the user that an error has occurred", ^{
                subject.explanatoryLabel.text should equal(@"An error has occurred. Would you like to try again?");
            });
            
            it(@"should allow the user to try again", ^{
                subject.yesButton.userInteractionEnabled should be_truthy;
                subject.yesButton.titleLabel.text should equal(@"Yes!");
                subject.yesButton.subviews should_not contain(spinner);
            });
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
