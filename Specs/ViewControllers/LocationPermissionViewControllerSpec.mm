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
    
    it(@"should title itself as Step 1", ^{
        subject.title should equal(@"Step 2: Location Permission");
    });
    
    it(@"should hide the back button", ^{
        subject.navigationItem.hidesBackButton should be_truthy;
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
            
            it(@"should tell the user that they've given permission", ^{
                subject.explanatoryLabel.text should contain(@"already given location permission");
            });
            
            it(@"should update the 'Yes' button to say 'Next'", ^{
                subject.yesButton.titleLabel.text should equal(@"Next");
            });
            
            it(@"should hide the 'No' button", ^{
                subject.noButton.hidden should be_truthy;
            });

            describe(@"tapping the 'Next' button", ^{
                beforeEach(^{
                    [subject.yesButton sendActionsForControlEvents:UIControlEventTouchUpInside];
                });
                
                it(@"should present the next step of the onboarding flow", ^{
                    navController.topViewController should be_instance_of([AlertPermissionViewController class]);
                });
            });
        });
        
        describe(@"when the user denies permission via the system dialog", ^{
            
            beforeEach(^{
                [subject.locationManager.delegate locationManager:subject.locationManager didChangeAuthorizationStatus:kCLAuthorizationStatusDenied];
                Class locationManagerClass = [subject.locationManager class];
                spy_on(locationManagerClass);
                locationManagerClass stub_method(@selector(authorizationStatus)).and_return(kCLAuthorizationStatusDenied);
            });
            
            
            it(@"should warn them that the app won't be useful", ^{
                subject.explanatoryLabel.text should contain(@"go to Settings");
                subject.explanatoryLabel.text should contain(@"will not function properly");
            });
            
            it(@"should update the Yes button to a 'Next' button", ^{
                subject.yesButton.titleLabel.text should equal(@"Next");
            });
            
            describe(@"tapping the next button", ^{
                beforeEach(^{
                    [subject.yesButton sendActionsForControlEvents:UIControlEventTouchUpInside];
                });
                
                it(@"should present the next step of the onboarding flow", ^{
                    navController.topViewController should be_instance_of([AlertPermissionViewController class]);
                });
                
            });
        });
    });

    describe(@"when the user taps NO", ^{
        beforeEach(^{
            [subject.noButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        });
        
        it(@"should warn them that the app won't be useful", ^{
            subject.explanatoryLabel.text should contain(@"go to Settings");
            subject.explanatoryLabel.text should contain(@"will not function properly");
        });
        
        it(@"should update the Yes button to a 'Next' button", ^{
            subject.yesButton.titleLabel.text should equal(@"Next");
        });
        
        describe(@"tapping the next button", ^{
            beforeEach(^{
                [subject.yesButton sendActionsForControlEvents:UIControlEventTouchUpInside];
            });
            
            it(@"should present the next step of the onboarding flow", ^{
                navController.topViewController should be_instance_of([AlertPermissionViewController class]);
            });

        });
    });
    
    context(@"when the user has already given location permisson", ^{
        beforeEach(^{
            [subject.locationManager.delegate locationManager:subject.locationManager didChangeAuthorizationStatus:kCLAuthorizationStatusAuthorizedAlways];
        });
        it(@"should tell the user that they've given permission", ^{
            subject.explanatoryLabel.text should contain(@"already given location permission");
        });
        
        it(@"should update the 'Yes' button to say 'Next'", ^{
            subject.yesButton.titleLabel.text should equal(@"Next");
        });
        
        it(@"should hide the 'No' button", ^{
            subject.noButton.hidden should be_truthy;
        });
    });
});

SPEC_END
