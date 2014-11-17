#import "MainViewController.h"
#import "TesselBeaconManager.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MainViewControllerSpec)

describe(@"MainViewController", ^{
    __block MainViewController *subject;
    __block TesselBeaconManager *beaconManager;
    
    beforeEach(^{
        beaconManager = nice_fake_for([TesselBeaconManager class]);
        subject = [[MainViewController alloc] initWithBeaconManager:beaconManager];
        subject.view should_not be_nil;
    });
    
    it(@"should assign itself as the tessel manager's delegate and the beacon manager's delegate", ^{
        beaconManager should have_received(@selector(registerDelegate:)).with(subject);
    });
    
    describe(@"tapping the scan button", ^{
        beforeEach(^{
            [subject.scanButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        });
        
        it(@"should tell the tesselManger to monitorProximityToBeacon", ^{
            beaconManager should have_received(@selector(monitorProximityToTesselBeacon));
        });
    });
    
    describe(@"responding to TesselBeaconManager events", ^{
        describe(@"entering the range of a Tessel", ^{
            beforeEach(^{
                [subject didEnterTesselRange];
            });
            
            it(@"should present an alert", ^{
                UIAlertController *alertController = (id)subject.presentedViewController;
                alertController should be_instance_of([UIAlertController class]);
                alertController.title should equal(@"Bonjour!");
                alertController.message should equal(@"You're near a Tessel");
            });
            
            it(@"should log that", ^{
                UITableViewCell *cell = [subject.tableView.visibleCells firstObject];
                cell.textLabel.text should contain(@"entered range of tessel");
            });
        });
        
        describe(@"exiing the range of a Tessel", ^{
            beforeEach(^{
                [subject didExitTesselRange];
            });
            
            it(@"should log that", ^{
                UITableViewCell *cell = [subject.tableView.visibleCells firstObject];
                cell.textLabel.text should contain(@"exited range of tessel");
            });
        });
        
        describe(@"when proximity to tessel gets updated", ^{
            it(@"should log when the Tessel is nearby", ^{
                [subject didUpdateProximityToTessel:CLProximityNear];
                UITableViewCell *cell = [subject.tableView.visibleCells firstObject];
                cell.textLabel.text should contain(@"proximity to tessel: NEAR");
            });

            it(@"should log when the Tessel is immediate", ^{
                [subject didUpdateProximityToTessel:CLProximityImmediate];
                UITableViewCell *cell = [subject.tableView.visibleCells firstObject];
                cell.textLabel.text should contain(@"proximity to tessel: IMMEDIATE");
            });
            
            it(@"should log when the Tessel is far", ^{
                [subject didUpdateProximityToTessel:CLProximityFar];
                UITableViewCell *cell = [subject.tableView.visibleCells firstObject];
                cell.textLabel.text should contain(@"proximity to tessel: FAR");
            });
        });
    
        describe(@"when failing to monitor the proximity to a Tessel", ^{
            it(@"should log the error and its explanation", ^{
                NSError *error = [[NSError alloc] initWithDomain:kCLErrorDomain code:kCLErrorRangingUnavailable userInfo:nil];
                [subject didFailToMonitorProximitityForTesselRegion:nil withErrorMessage:error];
                
                UITableViewCell *cell = [subject.tableView.visibleCells firstObject];
                cell.textLabel.text should contain(@"kCLErrorRangingUnavailable");
                cell.textLabel.text should contain(@"Ranging is disabled.");
            });
        });
    });

});

SPEC_END
