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
    });
    
    it(@"should assign itself as the tessel manager's delegate and the beacon manager's delegate", ^{
        subject.view should_not be_nil;

        beaconManager should have_received(@selector(registerDelegate:)).with(subject);
    });
    
    describe(@"configuring the switches correctly", ^{
        it(@"should toggle the proximity switch to ON when a region is being monitored", ^{
            beaconManager stub_method(@selector(isMonitoringProximityToTesselBeacon)).and_return(YES);
            subject.view should_not be_nil;
            
            subject.proximitySwitch.on should be_truthy;
        });
        
        it(@"should toggle the proximity switch to OFF when no region is being monitored", ^{
            beaconManager stub_method(@selector(isMonitoringProximityToTesselBeacon)).and_return(NO);
            subject.view should_not be_nil;
            
            subject.proximitySwitch.on should be_falsy;
        });
    });
    
    
    describe(@"toggling the proximity switch to ON", ^{
        beforeEach(^{
            subject.view should_not be_nil;

            [subject.proximitySwitch setOn:YES];

            [subject.proximitySwitch sendActionsForControlEvents:UIControlEventValueChanged];
        });
        
        it(@"should tell the tesselManger to monitorProximityToBeacon", ^{
            beaconManager should have_received(@selector(monitorProximityToTesselBeacon));
        });
        
        it(@"should log the event", ^{
            UITableViewCell *cell = [subject.tableView.visibleCells firstObject];
            cell.textLabel.text should contain(@"Will attempt to monitor proximity");
        });
        
        describe(@"toggling it back off", ^{
            beforeEach(^{
                [subject.proximitySwitch setOn:NO];
                [subject.proximitySwitch sendActionsForControlEvents:UIControlEventValueChanged];
            });
            
            it(@"should tell the tesselManager to stop monitoring the beacon's proximity", ^{
                beaconManager should have_received(@selector(stopMonitoringProximityToTessel));
            });
            
            it(@"should log the event", ^{
                UITableViewCell *cell = [subject.tableView.visibleCells lastObject];
                cell.textLabel.text should contain(@"Will stop monitoring and logging proximity");
            });

        });
    });
    
    describe(@"responding to TesselBeaconManager events", ^{
        beforeEach(^{
            subject.view should_not be_nil;
        });
        
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
