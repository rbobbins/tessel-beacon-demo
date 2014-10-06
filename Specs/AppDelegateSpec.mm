#import "AppDelegate.h"
#import "TesselBeaconManager.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(AppDelegateSpec)

describe(@"AppDelegate", ^{
    __block AppDelegate *subject;

    beforeEach(^{
        subject = [[AppDelegate alloc] init];
    });
    
    describe(@"-application:didFinishLaunchingWithOptions:", ^{
        __block UIApplication *fakeApplication;
        beforeEach(^{
            fakeApplication = nice_fake_for([UIApplication class]);
            [subject application:fakeApplication didFinishLaunchingWithOptions:nil];
        });
        
        it(@"should prompt the user for alert permissions", ^{
            fakeApplication should have_received(@selector(registerUserNotificationSettings:));
        });
        
        it(@"should initalize a TesselBeaconManager", ^{
            subject.tesselBeaconManager should be_instance_of([TesselBeaconManager class]);
            subject.tesselBeaconManager.locationManager should be_instance_of([CLLocationManager class]);
        });
    });
});

SPEC_END
