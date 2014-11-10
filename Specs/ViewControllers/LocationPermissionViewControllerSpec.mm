#import <Cedar/Cedar.h>
#import <CoreLocation/CoreLocation.h>
#import "LocationPermissionViewController.h"
#import "AlertPermissionViewController.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(LocationPermissionViewControllerSpec)

describe(@"LocationPermissionViewController", ^{
    __block LocationPermissionViewController *subject;
    __block UINavigationController *navController;

    beforeEach(^{
        subject = [[LocationPermissionViewController alloc] init];
        navController = [[UINavigationController alloc] initWithRootViewController:subject];
        subject.view should_not be_nil;
    });
    
    it(@"should explain what location will be used for", ^{
        subject.explanatoryLabel.text should contain(@"relative location to Tessel devices");
    });
    
    it(@"should allow the user to decide whether to give permission", ^{
        subject.yesButton.titleLabel.text should equal(@"Yes!");
        subject.noButton.titleLabel.text should equal(@"Maybe later");
    });
    
    it(@"should initalize a CLLocationManager, for requesting authorization", ^{
        subject.locationManager should be_instance_of([CLLocationManager class]);
    });
    
    describe(@"when the user taps Yes", ^{
        beforeEach(^{
            spy_on(subject.locationManager);
            subject.locationManager stub_method(@selector(requestAlwaysAuthorization));
            UIButton *button = subject.yesButton;
            [button sendActionsForControlEvents:UIControlEventTouchUpInside];
        });
        
        it(@"should prompt them with a system alert for permisson", ^{
            subject.locationManager should have_received(@selector(requestAlwaysAuthorization));
        });
        
        describe(@"when the user grants permission via system dialog", ^{
            beforeEach(^{
                [subject.locationManager.delegate locationManager:subject.locationManager didChangeAuthorizationStatus:kCLAuthorizationStatusAuthorizedAlways];
            });
            
            it(@"should present the next step of the onboarding flow", ^{
                navController.topViewController should be_instance_of([AlertPermissionViewController class]);
            });
        });
        
        describe(@"when the user denies permission via the system dialog", ^{
            
            beforeEach(^{
                [subject.locationManager.delegate locationManager:subject.locationManager didChangeAuthorizationStatus:kCLAuthorizationStatusDenied];
                Class locationManagerClass = [subject.locationManager class];
                spy_on(locationManagerClass);
                locationManagerClass stub_method(@selector(authorizationStatus)).and_return(kCLAuthorizationStatusDenied);
            });
            
            it(@"should change the 'Yes' button text", ^{
                subject.yesButton.titleLabel.text should equal(@"Yes, via device settings");
            });
            
            describe(@"subsquently tapping the 'Yes' button", ^{
                beforeEach(^{
                    [subject.yesButton sendActionsForControlEvents:UIControlEventTouchUpInside];
                });
                
                it(@"should present a 'Not implemented' alert view", ^{
                    UIAlertController *alertController = (id)subject.presentedViewController;
                    alertController should be_instance_of([UIAlertController class]);
                    alertController.message should equal(@"Not implemented yet");
                });
            });
        });
    });

    describe(@"when the user taps NO", ^{
        beforeEach(^{
            [subject.noButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        });
        
        it(@"should present the next step of the onboarding flow", ^{
            navController.topViewController should be_instance_of([AlertPermissionViewController class]);
        });
    });
});

SPEC_END
