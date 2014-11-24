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
    
    it(@"should title itself as Step 2", ^{
        subject.title should equal(@"Step 2: Notification Permission");
    });
    
    it(@"should hide the back button", ^{
        subject.navigationItem.hidesBackButton should be_truthy;
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
    });
    
    describe(@"when the user taps No", ^{
        beforeEach(^{
            spy_on(navController);
            [subject.noButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        });
        
        it(@"should pop back to the root view of the nav controller", ^{
            navController should have_received(@selector(popToRootViewControllerAnimated:));
        });
    });
});

SPEC_END
