#import "AppDelegate.h"
#import "TesselBeaconManager.h"
#import "MainViewController.h"
#import "WelcomeViewController.h"
#import "NSUserDefaults+Keys.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(AppDelegateSpec)

describe(@"AppDelegate", ^{
    __block AppDelegate *subject;
    __block UIApplication *fakeApplication;
    __block NSUserDefaults *fakeUserDefaults;


    beforeEach(^{
        subject = [[AppDelegate alloc] init];
        fakeApplication = nice_fake_for([UIApplication class]);
        fakeUserDefaults = nice_fake_for([NSUserDefaults class]);
        Class userDefaultsClass = [NSUserDefaults class];
        spy_on(userDefaultsClass);
        userDefaultsClass stub_method(@selector(standardUserDefaults)).and_return(fakeUserDefaults);;
    });
    
    describe(@"-application:didFinishLaunchingWithOptions:", ^{
        beforeEach(^{
        });
        
        context(@"when the user is a new user", ^{
            __block UINavigationController *navController;
            
            beforeEach(^{
                [subject application:fakeApplication didFinishLaunchingWithOptions:nil];
                navController = (id)subject.window.rootViewController;
            });
            
            it(@"should initalize a TesselBeaconManager", ^{
                subject.tesselBeaconManager should be_instance_of([TesselBeaconManager class]);
                subject.tesselBeaconManager.locationManager should be_instance_of([CLLocationManager class]);
            });
            
            it(@"should present the first step of the onboarding flow", ^{
                navController should be_instance_of([UINavigationController class]);
                navController.topViewController should be_instance_of([WelcomeViewController class]);
            });
            
            it(@"should not show a nav bar", ^{
                navController.navigationBarHidden should be_truthy;
            });
        });
        
        context(@"when the user has completed the onboarding flow already", ^{
            beforeEach(^{
                fakeUserDefaults stub_method(@selector(boolForKey:))
                    .with(kUserDidCompleteOnboarding)
                    .and_return(YES);
                [subject application:fakeApplication didFinishLaunchingWithOptions:nil];
            });
            
            it(@"should present the main view controller", ^{
                
                UINavigationController *navController = (id)subject.window.rootViewController;
                navController should be_instance_of([UINavigationController class]);
                navController.topViewController should be_instance_of([MainViewController class]);
                navController.navigationBarHidden should be_truthy;
            });
        });
    });
    
    describe(@"application:didRegisterUserNotificationSettings:", ^{
        context(@"registered settings include permission for local alerts", ^{
            __block UIUserNotificationSettings *settings;
            
            beforeEach(^{
                settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert categories:nil];
                [subject application:fakeApplication didFinishLaunchingWithOptions:nil];
                [subject application:nil didRegisterUserNotificationSettings:settings];
            });
            
            it(@"should present the main view controller", ^{
                UINavigationController *navController = (id)subject.window.rootViewController;
                navController should be_instance_of([UINavigationController class]);
                navController.topViewController should be_instance_of([MainViewController class]);
                navController.navigationBarHidden should be_truthy;
            });
            
            it(@"should save the settings in the user defaults", ^{
                fakeUserDefaults should have_received(@selector(setBool:forKey:)).with(YES, @"kUserNotificationSettingsAllowsAlert");
            });
        });
    });
});

SPEC_END
