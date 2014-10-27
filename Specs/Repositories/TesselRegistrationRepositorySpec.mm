#import <Cedar/Cedar.h>
#import "TesselRegistrationRepository.h"
#import <AFNetworking/AFURLRequestSerialization.h>
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import <CoreLocation/CoreLocation.h>
#import "KSPromise.h"
#import "NSUserDefaults+Keys.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(TesselRegistrationRepositorySpec)

describe(@"TesselRegistrationRepository", ^{
    __block TesselRegistrationRepository *subject;
    __block AFHTTPRequestOperationManager *requestOperationManager;

    beforeEach(^{
        requestOperationManager = nice_fake_for([AFHTTPRequestOperationManager class]);
        subject = [[TesselRegistrationRepository alloc] initWithRequestOperationManager:requestOperationManager];
    });

    describe(@"registering a new tessel", ^{
        __block void (^networkLevelSuccessBlock)(AFHTTPRequestOperation *, id);
        __block KSPromise *promise;

        beforeEach(^{
            requestOperationManager stub_method(@selector(POST:parameters:success:failure:)).and_do(^(NSInvocation *invocation) {
                void (^temp)(AFHTTPRequestOperation *, id);
                [invocation getArgument:&temp atIndex:4];
                networkLevelSuccessBlock = temp;
            });
            promise = [subject registerNewTessel];

            networkLevelSuccessBlock should_not be_nil;
        });

        it(@"should send the request to the request operation manager", ^{
            requestOperationManager should have_received(@selector(POST:parameters:success:failure:)).with(@"api/tessels", nil, Arguments::anything, Arguments::anything);
        });

        describe(@"after the network request succeds", ^{
            __block NSUserDefaults *userDefaults;

            beforeEach(^{
                userDefaults = [NSUserDefaults standardUserDefaults];
                spy_on(userDefaults);
                userDefaults stub_method(@selector(setValue:forKey:));

                NSDictionary *fixtureResponse = @{@"uuid": @"stubbed-uuid"};
                networkLevelSuccessBlock(nil, fixtureResponse);
            });

            it(@"should resolve the promise with the Tessel's unique ID", ^{
                promise.value should equal(@"stubbed-uuid");
            });

            it(@"should save the UUID to the user defaults", ^{
                userDefaults should have_received(@selector(setValue:forKey:)).with(@"stubbed-uuid",
                    kRegisteredTesselId);
            });
        });
    });


    describe(@"getting a list of registered Tessel regions", ^{
        __block NSUserDefaults *userDefaults;

        beforeEach(^{
            userDefaults = [NSUserDefaults standardUserDefaults];
            spy_on(userDefaults);
        });

        context(@"when the user of this phone/ipad has registered a tessel", ^{
            __block NSUUID *uuid;

            beforeEach(^{
                uuid = [NSUUID UUID];
                userDefaults stub_method(@selector(stringForKey:)).with(kRegisteredTesselId).and_return(uuid.UUIDString);
            });
            it(@"should return a list containing 1 region - with the UUID registered by this phone", ^{
                [subject registeredTesselRegions].count should equal(1);

                CLBeaconRegion *beaconRegion = [[subject registeredTesselRegions] firstObject];
                beaconRegion should be_instance_of([CLBeaconRegion class]);
                beaconRegion.proximityUUID should equal(uuid);
                beaconRegion.identifier should equal(@"");
            });
        });

        context(@"when the user of this phone/ipad has not registered a Tessel", ^{
            it(@"should return an empty list", ^{
               [subject registeredTesselRegions] should equal(@[]);
            });
        });


    });
});

SPEC_END
