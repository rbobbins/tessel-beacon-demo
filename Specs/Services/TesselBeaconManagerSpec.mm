#import "TesselBeaconManager.h"
#import <CoreLocation/CoreLocation.h>
#import "TesselCheckinRepository.h"
#import "TesselRegistrationRepository.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(TesselBeaconManagerSpec)

describe(@"TesselBeaconManager", ^{
    __block TesselBeaconManager *subject;
    __block CLLocationManager *fakeLocationManager;
    __block CLBeaconRegion *region;
    __block TesselCheckinRepository *tesselCheckinRepository;
    __block TesselRegistrationRepository *tesselRegistrationRepository;
    __block id<TesselBeaconDelegate> fakeBeaconDelegate;

    beforeEach(^{
        NSUUID *uuid = [NSUUID UUID];

        region = nice_fake_for([CLBeaconRegion class]);
        region stub_method(@selector(proximityUUID)).and_return(uuid);

        fakeLocationManager = nice_fake_for([CLLocationManager class]);
        tesselCheckinRepository = nice_fake_for([TesselCheckinRepository class]);
        tesselRegistrationRepository = nice_fake_for([TesselRegistrationRepository class]);
        tesselRegistrationRepository stub_method(@selector(registeredTesselRegion)).and_return(region);

        subject = [[TesselBeaconManager alloc] initWithLocationManager:fakeLocationManager
                                               tesselCheckinRepository:tesselCheckinRepository
                                          tesselRegistrationRepository:tesselRegistrationRepository];
        fakeLocationManager stub_method(@selector(delegate)).and_return(subject);
        fakeBeaconDelegate = nice_fake_for(@protocol(TesselBeaconDelegate));
        subject.delegate = fakeBeaconDelegate;
    });

    it(@"should register itself as the location manager's delegate", ^{
        fakeLocationManager should have_received(@selector(setDelegate:)).with(subject);
    });

    describe(@"-beginMonitoringTesselRegion:", ^{
        __block Class locationManagerClass;

        beforeEach(^{
            locationManagerClass = [CLLocationManager class];
            spy_on(locationManagerClass);
        });

        describe(@"when CLLocationManager auth status is AuthorizedAlways ", ^{
            beforeEach(^{
                locationManagerClass stub_method(@selector(authorizationStatus)).and_return(kCLAuthorizationStatusAuthorizedAlways);
                [subject startMonitoringTesselRegion];
            });

            it(@"should request a list of regions to monitor", ^{
                tesselRegistrationRepository should have_received(@selector(registeredTesselRegion));
            });

            it(@"should begin monitoring for the region", ^{
                fakeLocationManager should have_received(@selector(startMonitoringForRegion:)).with(region);
            });
        });

        describe(@"when CLLocationManager auth status is Undetermined", ^{
            beforeEach(^{
                locationManagerClass stub_method(@selector(authorizationStatus)).and_return(kCLAuthorizationStatusNotDetermined);
                [subject startMonitoringTesselRegion];
            });

            it(@"should prompt the user for permisson to monitor location", ^{
                fakeLocationManager should have_received(@selector(requestAlwaysAuthorization));
            });
            
            it(@"should tell its delegate that an error occurred, but it can try again", ^{
                NSError *expectedError = [[NSError alloc] initWithDomain:kTesselErrorDomain
                                                                    code:TesselWarningUndeterminedPermissionUserShouldTryAgain
                                                                userInfo:nil];
                fakeBeaconDelegate should have_received(@selector(monitoringFailedWithError:)).with(expectedError);
            });
        });
        
        describe(@"when authorization status is anything else", ^{
            beforeEach(^{
                locationManagerClass stub_method(@selector(authorizationStatus)).and_return(kCLAuthorizationStatusDenied);
                [subject startMonitoringTesselRegion];
            });
            
            it(@"should tell its delegate that monitoring failed due to being explicitly denied permission", ^{
                NSError *expectedError = [[NSError alloc] initWithDomain:kTesselErrorDomain
                                                                    code:TesselErrorInsufficientPermission
                                                                userInfo:nil];
                fakeBeaconDelegate should have_received(@selector(monitoringFailedWithError:)).with(expectedError);
            });
        });
    });

    describe(@"-stopMonitoringTesselRegion", ^{
        it(@"should tell the location manager to stop monitoring", ^{
            [subject stopMonitoringTesselRegion];
            fakeLocationManager should have_received(@selector(stopMonitoringForRegion:)).with(region);
        });
    });
    
    describe(@"-startRangingTesselRegion", ^{
        __block Class locationManagerClass;
        
        beforeEach(^{
            locationManagerClass = [CLLocationManager class];
            spy_on(locationManagerClass);
        });
        
        context(@"when permission level is AuthorizedAlways", ^{
            beforeEach(^{
                locationManagerClass stub_method(@selector(authorizationStatus)).and_return(kCLAuthorizationStatusAuthorizedAlways);
                [subject startRangingTesselRegion];
            });
            
            it(@"should begin ranging for beacon", ^{
                fakeLocationManager should have_received(@selector(startRangingBeaconsInRegion:)).with(region);
            });
            
            describe(@"when ranging is succesful", ^{
                beforeEach(^{
                    CLBeacon *beacon = nice_fake_for([CLBeacon class]);
                    beacon stub_method(@selector(proximity)).and_return(CLProximityImmediate);
                    [fakeLocationManager.delegate locationManager:fakeLocationManager
                                                  didRangeBeacons:@[beacon]
                                                         inRegion:region];
                });
                
                it(@"should inform any registered delegates", ^{
                    fakeBeaconDelegate should have_received(@selector(rangingSucceededWithProximity:)).with(CLProximityImmediate);
                });
            });
            
            describe(@"when ranging fails", ^{
                __block NSError *error;
                beforeEach(^{
                    error = nice_fake_for([NSError class]);
                    [fakeLocationManager.delegate locationManager:fakeLocationManager rangingBeaconsDidFailForRegion:region withError:error];
                });
                
                it(@"should inform its delegate", ^{
                    fakeBeaconDelegate should have_received(@selector(rangingFailedWithError:)).with(error);
                });
            });
        });
        
        context(@"when authorization status NotDetermined ", ^{
            beforeEach(^{
                locationManagerClass stub_method(@selector(authorizationStatus)).and_return(kCLAuthorizationStatusNotDetermined);
                [subject startRangingTesselRegion];
            });
            
            it(@"should request authorization", ^{
                fakeLocationManager should have_received(@selector(requestAlwaysAuthorization));
            });
            
            it(@"should tell its delegate that an error occured, but it should try again", ^{
                NSError *expectedError = [[NSError alloc] initWithDomain:kTesselErrorDomain
                                                                    code:TesselWarningUndeterminedPermissionUserShouldTryAgain
                                                                userInfo:nil];
                fakeBeaconDelegate should have_received(@selector(rangingFailedWithError:)).with(expectedError);
            });
        });
        
        context(@"when authorization status is anything else NotDetermined ", ^{
            beforeEach(^{
                locationManagerClass stub_method(@selector(authorizationStatus)).and_return(kCLAuthorizationStatusDenied);
                [subject startRangingTesselRegion];
            });
            
            it(@"should tell its delegate that an error occured, but it should try again", ^{
                NSError *expectedError = [[NSError alloc] initWithDomain:kTesselErrorDomain
                                                                    code:TesselErrorInsufficientPermission
                                                                userInfo:nil];
                fakeBeaconDelegate should have_received(@selector(rangingFailedWithError:)).with(expectedError);
            });
        });
    });
    
    describe(@"-stopRangingTesselRegion", ^{
        
        context(@"when the Tessel's proximity is being monitored", ^{
            
            beforeEach(^{
                fakeLocationManager stub_method(@selector(rangedRegions)).and_return([NSSet setWithObject:region]);
            });
            
            it(@"should tell the location manager to stop ranging", ^{
                [subject stopRangingTesselRegion];
                fakeLocationManager should have_received(@selector(stopRangingBeaconsInRegion:)).with(region);
            });
        });
        
    });
    
    describe(@"responding to location events", ^{
        describe(@"when location manager authorization status changes", ^{
            
            context(@"when it is kCLAuthorizationStatusAuthorizedAlways", ^{
                __block UIApplication *application;
                
                beforeEach(^{
                    application = [UIApplication sharedApplication];
                    spy_on(application);
                    application stub_method(@selector(registerUserNotificationSettings:));
                    
                    [fakeLocationManager.delegate locationManager:fakeLocationManager
                                     didChangeAuthorizationStatus:kCLAuthorizationStatusAuthorizedAlways];
                });
                
                it(@"should prompt them to allow notifications", ^{
                    application should have_received(@selector(registerUserNotificationSettings:));
                });
            });
        });

        describe(@"upon entering the region of a known tessel beacon", ^{
            __block UIApplication *application;

            beforeEach(^{
                application = [UIApplication sharedApplication];
                spy_on(application);
                application stub_method(@selector(presentLocalNotificationNow:));
                [fakeLocationManager.delegate locationManager:fakeLocationManager
                                               didEnterRegion:region];
            });


            it(@"should inform any registered delegates", ^{
                fakeBeaconDelegate should have_received(@selector(didEnterTesselRange));
            });

            it(@"should immediately present a local notification", ^{
                application should have_received(@selector(presentLocalNotificationNow:));
            });

            it(@"should post a checkin", ^{
                tesselCheckinRepository should have_received(@selector(checkinAtTessel:)).with(region.proximityUUID);
            });
        });

        describe(@"upon exiting the region of a known tessel beacon", ^{
            beforeEach(^{
                [fakeLocationManager.delegate locationManager:fakeLocationManager
                                                didExitRegion:region];
            });

            it(@"should stop ranging the beacon", ^{
                fakeLocationManager should have_received(@selector(stopRangingBeaconsInRegion:)).with(region);
            });

            it(@"should inform any registered delegates", ^{
                fakeBeaconDelegate should have_received(@selector(didExitTesselRange));
            });
        });

    });



});

SPEC_END
