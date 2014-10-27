#import <Cedar/Cedar.h>
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import "TesselCheckinRepository.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(TesselCheckinRepositorySpec)

describe(@"TesselCheckinRepository", ^{
    __block TesselCheckinRepository *subject;
    __block AFHTTPRequestOperationManager *requestOperationManager;
    __block NSUUID *tesselUUID;
    __block NSUUID *deviceUUID;

    beforeEach(^{
        tesselUUID = [NSUUID UUID];
        deviceUUID = [NSUUID UUID];

        requestOperationManager = nice_fake_for([AFHTTPRequestOperationManager class]);
        subject = [[TesselCheckinRepository alloc] initWithRequestOperationManager:requestOperationManager];
    });

    describe(@"checking in at a Tessel", ^{
        __block UIDevice *device;
        beforeEach(^{
            device = [UIDevice currentDevice];
            spy_on(device);
            device stub_method(@selector(identifierForVendor)).and_return(deviceUUID);
            
            [subject checkinAtTessel:tesselUUID];
        });

        it(@"should post to the correct url", ^{
            NSDictionary *expectedParameters = @{@"checkin": @{@"device_id": deviceUUID.UUIDString}};
            NSString *expectedURLString = [NSString stringWithFormat:@"api/tessels/%@/checkin", tesselUUID.UUIDString];

            requestOperationManager should have_received(@selector(POST:parameters:success:failure:))
                .with(expectedURLString, expectedParameters, nil, nil);
        });
    });
});

SPEC_END
