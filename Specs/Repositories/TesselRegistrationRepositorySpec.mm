#import <Cedar/Cedar.h>
#import "TesselRegistrationRepository.h"
#import <AFNetworking/AFURLRequestSerialization.h>
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import "KSPromise.h"

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
            beforeEach(^{
                NSDictionary *fixtureResponse = @{@"uuid": @"stubbed-uuid"};
                networkLevelSuccessBlock(nil, fixtureResponse);
            });
            
            it(@"should resolve the promise with the Tessel's unique ID", ^{
                promise.value should equal(@"stubbed-uuid");
            });
        });
    });
});

SPEC_END
