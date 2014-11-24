#import "AppDelegate.h"
#import "TesselBeaconManager.h"
#import "MainViewController.h"
#import "NSUserDefaults+Keys.h"
#import "RegistrationViewController.h"
#import "WelcomeViewController.h"


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
        context(@"when the user has not yet registered a Tessel", ^{
            beforeEach(^{
                fakeUserDefaults stub_method(@selector(stringForKey:))
                    .with(kRegisteredTesselId)
                    .and_return(nil);
                
                [subject application:fakeApplication didFinishLaunchingWithOptions:nil];

            });
            
            it(@"should initalize a TesselBeaconManager", ^{
                subject.tesselBeaconManager should be_instance_of([TesselBeaconManager class]);
                subject.tesselBeaconManager.locationManager should be_instance_of([CLLocationManager class]);

            });
            
            describe(@"intializing the view hierarchy", ^{
                __block UINavigationController *navController;

                beforeEach(^{
                    navController = (id)subject.window.rootViewController;
                });
                
                it(@"should set a navigation controller as the root view of the window", ^{
                    navController should be_instance_of([UINavigationController class]);
                });
                
                it(@"should present the first step of the onboarding flow", ^{
                    navController.topViewController should be_instance_of([WelcomeViewController class]);
                });
                
                it(@"should set the MainViewController as the root of the nav hierarhy (even though it'll be hidden)", ^{
                    [navController.viewControllers firstObject] should be_instance_of([MainViewController class]); 
                });
            });
        });
        
        context(@"when the user has already registered a Tessel", ^{
            beforeEach(^{
                NSString *uuidString = [NSUUID UUID].UUIDString;
                fakeUserDefaults stub_method(@selector(stringForKey:))
                    .with(kRegisteredTesselId)
                    .and_return(uuidString);
                [subject application:fakeApplication didFinishLaunchingWithOptions:nil];
            });
            
            it(@"should present the main view controller", ^{
                UINavigationController *navController = (id)subject.window.rootViewController;
                navController should be_instance_of([UINavigationController class]);
                navController.topViewController should be_instance_of([MainViewController class]);
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
