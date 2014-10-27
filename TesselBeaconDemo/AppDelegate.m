//
//  AppDelegate.m
//  TesselBluetoothDemo
//
//  Created by Rachel Bobbins on 9/30/14.
//  Copyright (c) 2014 Rachel Bobbins. All rights reserved.
//
#import "AppDelegate.h"
#import "MainViewController.h"
#import "TesselBeaconManager.h"
#import "WelcomeViewController.h"
#import "TesselRegistrationRepository.h"
#import "NSUserDefaults+Keys.h"
#import "TesselCheckinRepository.h"
#import <CoreLocation/CoreLocation.h>
#import <AFNetworking/AFNetworking.h>

@interface AppDelegate ()
@property (nonatomic) TesselBeaconManager *tesselBeaconManager;
@end

@implementation AppDelegate


#pragma mark - <UIApplicationDelegate>

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    NSURL *baseURL = [NSURL URLWithString:@"https://[YOUR REMOTE SERVER]/"];
    AFHTTPRequestOperationManager *requestOperationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
    
    TesselCheckinRepository *tesselCheckinRepository = [[TesselCheckinRepository alloc]
        initWithRequestOperationManager:requestOperationManager];
    TesselRegistrationRepository *tesselRegistrationRepository = [[TesselRegistrationRepository alloc] initWithRequestOperationManager:requestOperationManager];
    self.tesselBeaconManager = [[TesselBeaconManager alloc] initWithLocationManager:locationManager
                                                            tesselCheckinRepository:tesselCheckinRepository
                                                       tesselRegistrationRepository:tesselRegistrationRepository];


    UIViewController *initialViewController;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([userDefaults boolForKey:kUserDidCompleteOnboarding]) {
        initialViewController = [[MainViewController alloc] initWithBeaconManager:self.tesselBeaconManager];
    } else {
       initialViewController = [[WelcomeViewController alloc] initWithTesselRegistrationRepository:tesselRegistrationRepository];
    }

    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:initialViewController];
    navController.navigationBarHidden = YES;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = navController;

    [self.window makeKeyAndVisible];
    return YES;
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    if (notificationSettings.types & UIUserNotificationTypeAlert) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserNotificationSettingsAllowsAlert];
    }
        MainViewController *viewController = [[MainViewController alloc] initWithBeaconManager:self.tesselBeaconManager];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    navController.navigationBarHidden = YES;
    self.window.rootViewController = navController;

}


@end
