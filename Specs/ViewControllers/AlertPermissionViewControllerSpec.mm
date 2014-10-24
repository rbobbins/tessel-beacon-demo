#import <Cedar/Cedar.h>
#import "AlertPermissionViewController.h"
#import "MainViewController.h"
#import "NSUserDefaults+Keys.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(AlertPermissionViewControllerSpec)

describe(@"AlertPermissionViewController", ^{
    __block AlertPermissionViewController *subject;
    __block UINavigationController *navController;
    __block NSUserDefaults *fakeUserDefaults;
    
    beforeEach(^{
        fakeUserDefaults = nice_fake_for([NSUserDefaults class]);
        Class userDefaultsClass = [NSUserDefaults class];
        spy_on(userDefaultsClass);
        userDefaultsClass stub_method(@selector(standardUserDefaults)).and_return(fakeUserDefaults);
        
        subject = [[AlertPermissionViewController alloc] init];
        navController = [[UINavigationController alloc] initWithRootViewController:subject];
        subject.view should_not be_nil;
    });
    
    it(@"should explain the value of notifications", ^{
        subject.explanatoryLabel.text should contain(@"notified when you're near a Tessel?");
    });
    
    it(@"should allow the user to choose whether they want notifcations", ^{
        subject.yesButton.titleLabel.text should equal(@"Yes!");
        subject.noButton.titleLabel.text should equal(@"Maybe later");
    });
    
    describe(@"when the user taps Yes!", ^{
        __block UIApplication *application;
        
        beforeEach(^{
            application = [UIApplication sharedApplication];
            spy_on(application);
            application stub_method(@selector(registerUserNotificationSettings:));
            [subject.yesButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        });
        
        it(@"should prompt them to allow notifications", ^{
            application should have_received(@selector(registerUserNotificationSettings:));
        });
        
        it(@"should mark them as having completed the onboarding flow", ^{
            fakeUserDefaults should have_received(@selector(setBool:forKey:)).with(YES, kUserDidCompleteOnboarding);
        });
    });
    
    describe(@"when the user taps No", ^{
        beforeEach(^{
            [subject.noButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        });
        
        it(@"should reset the nav controller to only contain the MainViewController", ^{
            navController.topViewController should be_instance_of([MainViewController class]);
            navController.viewControllers.count should equal(1);
        });
        
        it(@"should mark them as having completed the onboarding flow", ^{
            fakeUserDefaults should have_received(@selector(setBool:forKey:)).with(YES, kUserDidCompleteOnboarding);
        });
    });
});

SPEC_END
