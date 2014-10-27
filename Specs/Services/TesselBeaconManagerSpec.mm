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


    beforeEach(^{
        NSUUID *uuid = [NSUUID UUID];

        region = nice_fake_for([CLBeaconRegion class]);
        region stub_method(@selector(proximityUUID)).and_return(uuid);

        fakeLocationManager = nice_fake_for([CLLocationManager class]);
        tesselCheckinRepository = nice_fake_for([TesselCheckinRepository class]);
        tesselRegistrationRepository = nice_fake_for([TesselRegistrationRepository class]);
        tesselRegistrationRepository stub_method(@selector(registeredTesselRegions)).and_return(@[region]);

        subject = [[TesselBeaconManager alloc] initWithLocationManager:fakeLocationManager
                                               tesselCheckinRepository:tesselCheckinRepository
                                          tesselRegistrationRepository:tesselRegistrationRepository];
        fakeLocationManager stub_method(@selector(delegate)).and_return(subject);
    });

    it(@"should register itself as the location manager's delegate", ^{
        fakeLocationManager should have_received(@selector(setDelegate:)).with(subject);
    });

    describe(@"-searchForTesselBeacons:", ^{
        __block Class locationManagerClass;

        beforeEach(^{
            locationManagerClass = [CLLocationManager class];
            spy_on(locationManagerClass);
        });

        describe(@"when CLLocationManager auth status is AuthorizedAlways ", ^{
            beforeEach(^{
                locationManagerClass stub_method(@selector(authorizationStatus)).and_return(kCLAuthorizationStatusAuthorizedAlways);
                [subject searchForTesselBeacon];
            });

            it(@"should request a list of regions to monitor", ^{
                tesselRegistrationRepository should have_received(@selector(registeredTesselRegions));
            });

            it(@"should begin monitoring for the region", ^{
                fakeLocationManager should have_received(@selector(startMonitoringForRegion:)).with(region);
            });
        });

        describe(@"when CLLocationManager auth status is Undetermined", ^{
            beforeEach(^{
                locationManagerClass stub_method(@selector(authorizationStatus)).and_return(kCLAuthorizationStatusNotDetermined);
                [subject searchForTesselBeacon];
            });

            it(@"should prompt the user for permisson to monitor location", ^{
                fakeLocationManager should have_received(@selector(requestAlwaysAuthorization));
            });
        });
    });

    describe(@"responding to location events", ^{
        __block id<TesselBeaconDelegate> fakeBeaconDelegate;

        beforeEach(^{
            fakeBeaconDelegate = nice_fake_for(@protocol(TesselBeaconDelegate));
            [subject registerDelegate:fakeBeaconDelegate];
        });

        describe(@"when location manager authorization status changes", ^{
            context(@"when it is kCLAuthorizationStatusAuthorizedAlways", ^{
                beforeEach(^{
                    [fakeLocationManager.delegate locationManager:fakeLocationManager
                                     didChangeAuthorizationStatus:kCLAuthorizationStatusAuthorizedAlways];
                });

                it(@"should begin monitoring tessel regions", ^{
                    fakeLocationManager should have_received(@selector(startMonitoringForRegion:)).with(region);
                });
            });

            context(@"when it is kCLAuthorizationStatusAuthorizedWhenInUse", ^{
                beforeEach(^{
                    [fakeLocationManager.delegate locationManager:fakeLocationManager
                                     didChangeAuthorizationStatus:kCLAuthorizationStatusAuthorizedWhenInUse];
                });

                it(@"should begin monitoring tessel regions", ^{
                    fakeLocationManager should_not have_received(@selector(startMonitoringForRegion:));
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

            it(@"should start ranging the beacon, in order to stay informed of beacon ", ^{
                fakeLocationManager should have_received(@selector(startRangingBeaconsInRegion:)).with(region);
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

        describe(@"whenever the proximity to the tessel changes", ^{
            beforeEach(^{

                CLBeacon *beacon = nice_fake_for([CLBeacon class]);
                beacon stub_method(@selector(proximity)).and_return(CLProximityImmediate);
                [fakeLocationManager.delegate locationManager:fakeLocationManager
                                              didRangeBeacons:@[beacon]
                                                     inRegion:region];
            });

            it(@"should inform any registered delegates", ^{
                fakeBeaconDelegate should have_received(@selector(didUpdateProximityToTessel:)).with(CLProximityImmediate);
            });
        });
    });



});

SPEC_END
