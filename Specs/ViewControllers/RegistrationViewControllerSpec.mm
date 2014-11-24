#import <Cedar/Cedar.h>
#import "RegistrationViewController.h"
#import "TesselRegistrationRepository.h"
#import "KSDeferred.h"
#import "TesselInformationViewController.h"
#import <CoreLocation/CoreLocation.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(RegistrationViewControllerSpec)

describe(@"RegistrationViewController", ^{
    __block UIViewController *rootViewController;
    __block RegistrationViewController *subject;
    __block UINavigationController *navController;
    __block TesselRegistrationRepository *registrationRepository;

    beforeEach(^{
        rootViewController = [[UIViewController alloc] init];
        navController = [[UINavigationController alloc] initWithRootViewController:rootViewController];

        registrationRepository = nice_fake_for([TesselRegistrationRepository class]);
        subject = [[RegistrationViewController alloc] initWithTesselRegistrationRepository:registrationRepository];
        [navController pushViewController:subject animated:NO];
    });

    
    context(@"when the user has not yet registered a Tessel", ^{
        beforeEach(^{
            subject.view should_not be_nil;
        });
        
        it(@"should title itself as Setup Your Tessel", ^{
            subject.title should equal(@"Setup Your Tessel");
        });
        
        it(@"should hide the back button", ^{
            subject.navigationItem.hidesBackButton should be_truthy;
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
            
            beforeEach(^{
                deferred = [KSDeferred defer];
                registrationRepository stub_method(@selector(registerNewTessel)).and_return(deferred.promise);
                [subject.yesButton sendActionsForControlEvents:UIControlEventTouchUpInside];
            });
            
            it(@"should send a request to register a Tessel", ^{
                registrationRepository should have_received(@selector(registerNewTessel));
            });
            
            it(@"should display a spinner", ^{
                subject.spinner should be_instance_of([UIActivityIndicatorView class]);
                subject.spinner.isAnimating should be_truthy;
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
                
                it(@"should pop back to the root view of the nav controller ", ^{
                    [subject dismissViewControllerAnimated:NO completion:nil];
                    navController.topViewController should be_same_instance_as(rootViewController);
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
                    subject.spinner.isAnimating should be_falsy;
                });
            });
        });
        
        describe(@"when the user taps No", ^{
            beforeEach(^{
                [subject.noButton sendActionsForControlEvents:UIControlEventTouchUpInside];
            });
            
            it(@"should pop back to the root view controller", ^{
                navController.topViewController should be_same_instance_as(rootViewController);
            });
        });
    });
    
    context(@"when the user has already registered a Tessel", ^{
        __block NSUUID *regionUUID;
        
        beforeEach(^{
            regionUUID = [NSUUID UUID];
            CLBeaconRegion *region = nice_fake_for([CLBeaconRegion class]);
            region stub_method(@selector(proximityUUID)).and_return(regionUUID);
            registrationRepository stub_method(@selector(registeredTesselRegion)).and_return(region);
            
            subject.view should_not be_nil;
        });
        
        it(@"should immediately present their tessel's information", ^{
            subject.presentedViewController should be_instance_of([TesselInformationViewController class]);
        });
    });
    
});

SPEC_END
