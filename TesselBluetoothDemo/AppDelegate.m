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
#import "TesselRegionManager.h"
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate ()
@property (nonatomic) TesselBeaconManager *tesselBeaconManager;
@end

@implementation AppDelegate


#pragma mark - <UIApplicationDelegate>

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    TesselRegionManager *tesselRegionManager = [[TesselRegionManager alloc] init];
    self.tesselBeaconManager = [[TesselBeaconManager alloc] initWithLocationManager:locationManager
                                                                tesselRegionManager:tesselRegionManager];
   
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    
    MainViewController *viewController = [[MainViewController alloc] initWithBeaconManager:self.tesselBeaconManager];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = viewController;

    [self.window makeKeyAndVisible];
    return YES;
}


@end
