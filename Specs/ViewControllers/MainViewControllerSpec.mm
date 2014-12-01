#import "MainViewController.h"
#import "TesselBeaconManager.h"
#import "TesselInformationViewController.h"

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
    
    describe(@"configuring the switches correctly", ^{
        it(@"should toggle the proximity switch to ON when a beacon is being ranged", ^{
            beaconManager stub_method(@selector(isRangingTesselRegion)).and_return(YES);
            subject.view should_not be_nil;
            
            subject.rangingSwitch.on should be_truthy;
        });
        
        it(@"should toggle the ranging switch to OFF when no region is being ranged", ^{
            beaconManager stub_method(@selector(isRangingTesselRegion)).and_return(NO);
            subject.view should_not be_nil;
            
            subject.rangingSwitch.on should be_falsy;
        });
        
        it(@"should toggle the region monitoring switch to ON when a region is being monitored", ^{
            beaconManager stub_method(@selector(isMonitoringTesselRegion)).and_return(YES);
            subject.view should_not be_nil;
            subject.monitoringSwitch.on should be_truthy;
        });
        
        it(@"should toggle the region monitoring switch to OFF when no region is being monitored", ^{
            beaconManager stub_method(@selector(isMonitoringTesselRegion)).and_return(NO);
            subject.view should_not be_nil;
            subject.monitoringSwitch.on should be_falsy;
        });
    });
    
    describe(@"toggling the proximity switch", ^{
        beforeEach(^{
            subject.view should_not be_nil;

            [subject.rangingSwitch setOn:YES];

            [subject.rangingSwitch sendActionsForControlEvents:UIControlEventValueChanged];
        });
        
        it(@"should tell the tesselManger to monitorProximityToBeacon", ^{
            beaconManager should have_received(@selector(startRangingTesselRegion));
        });
        
        it(@"should log the event", ^{
            UITableViewCell *cell = [subject.tableView.visibleCells firstObject];
            cell.textLabel.text should contain(@"ranging ON. Will log proximity to tessel beaco");
        });
        
        describe(@"toggling it back off", ^{
            beforeEach(^{
                [subject.rangingSwitch setOn:NO];
                [subject.rangingSwitch sendActionsForControlEvents:UIControlEventValueChanged];
            });
            
            it(@"should tell the tesselManager to stop monitoring the beacon's proximity", ^{
                beaconManager should have_received(@selector(stopRangingTesselRegion));
            });
            
            it(@"should log the event", ^{
                UITableViewCell *cell = [subject.tableView.visibleCells firstObject];
                cell.textLabel.text should contain(@"ranging OFF. Will stop logging proximity to tessel beacon");
            });

        });
    });
    
    describe(@"toggling the monitoring switch", ^{
        beforeEach(^{
            subject.view should_not be_nil;
            subject.monitoringSwitch.on = YES;
            [subject.monitoringSwitch sendActionsForControlEvents:UIControlEventValueChanged];
        });
        
        it(@"should tell the beacon manager to begin monitoring when toggled on", ^{
            beaconManager should have_received(@selector(startMonitoringTesselRegion));
        });
        
        it(@"should log that", ^{
            UITableViewCell *cell = [subject.tableView.visibleCells firstObject];
            cell.textLabel.text should contain(@"boundary monitoring ON");
        });
        
        describe(@"when toggled again", ^{
            beforeEach(^{
                subject.monitoringSwitch.on = NO;
                [subject.monitoringSwitch sendActionsForControlEvents:UIControlEventValueChanged];
            });
            it(@"should tell the beacon manager to stop monitoring", ^{
                beaconManager should have_received(@selector(stopMonitoringTesselRegion));
            });
            
            it(@"should log that", ^{
                UITableViewCell *cell = [subject.tableView.visibleCells firstObject];
                cell.textLabel.text should contain(@"boundary monitoring OFF");
            });
        });
    });
    
    describe(@"tapping a cell", ^{
        beforeEach(^{
            subject.view should_not be_nil;
            
            //Trigger an event that logs something
            [subject didExitTesselRange];
            
            [subject.tableView.delegate tableView:subject.tableView
                          didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        });
        
        it(@"should present an alert with the cell's full text, or a more verbose description", ^{
            UIAlertController *alertController = (id)subject.presentedViewController;
            alertController should be_instance_of([UIAlertController class]);
            alertController.title should equal(@"");
            alertController.message should contain(@"Exited range of tessel");
        });
    });
    
    describe(@"tapping the My Tessel button", ^{
        __block UINavigationController *navController;

        beforeEach(^{
            subject.view should_not be_nil;
            navController = [[UINavigationController alloc] initWithRootViewController:subject];
            [subject.myTesselButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        });
        
        it(@"should push a TesselInformationViewController", ^{
            navController.topViewController should be_instance_of([TesselInformationViewController class]);
        });
        
        it(@"should un-hide the navbar, so user can get back to this screen", ^{
            navController.topViewController.navigationController.navigationBarHidden should be_falsy;
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
                cell.textLabel.text should contain(@"Entered range of tessel");
            });
        });
        
        describe(@"exiting the range of a Tessel", ^{
            beforeEach(^{
                [subject didExitTesselRange];
            });
            
            it(@"should log that", ^{
                UITableViewCell *cell = [subject.tableView.visibleCells firstObject];
                cell.textLabel.text should contain(@"Exited range of tessel");
            });
        });
        
        describe(@"when proximity to tessel gets updated", ^{
            it(@"should log when the Tessel is nearby", ^{
                [subject rangingSucceededWithProximity:CLProximityNear];
                UITableViewCell *cell = [subject.tableView.visibleCells firstObject];
                cell.textLabel.text should contain(@"Proximity to tessel: NEAR");
            });

            it(@"should log when the Tessel is immediate", ^{
                [subject rangingSucceededWithProximity:CLProximityImmediate];
                UITableViewCell *cell = [subject.tableView.visibleCells firstObject];
                cell.textLabel.text should contain(@"Proximity to tessel: IMMEDIATE");
            });
            
            it(@"should log when the Tessel is far", ^{
                [subject rangingSucceededWithProximity:CLProximityFar];
                UITableViewCell *cell = [subject.tableView.visibleCells firstObject];
                cell.textLabel.text should contain(@"Proximity to tessel: FAR");
            });
        });
    
        describe(@"when failing to range a Tessel", ^{
            __block NSError *error;
            
            beforeEach(^{
                subject.rangingSwitch.on = YES;
                error = [[NSError alloc] initWithDomain:kCLErrorDomain code:kCLErrorRangingUnavailable userInfo:nil];
                [subject rangingFailedWithError:error];
            });
            
            it(@"should log the error and its explanation", ^{
                UITableViewCell *cell = [subject.tableView.visibleCells firstObject];
                cell.textLabel.text should contain(@"kCLErrorRangingUnavailable");
                cell.textLabel.text should contain(@"tap for more details");
            });
            
            it(@"should turn the ranging switch off", ^{
                subject.rangingSwitch.on should be_falsy;
            });
        });
    
        describe(@"when failing to monitor a Tessel", ^{
            beforeEach(^{
                subject.monitoringSwitch.on = YES;
                NSError *error = [[NSError alloc] initWithDomain:kCLErrorDomain
                                                            code:kCLErrorRegionMonitoringFailure userInfo:nil];
                [subject monitoringFailedWithError:error];
            });
            
            it(@"should log the error", ^{
                UITableViewCell *cell = [subject.tableView.visibleCells firstObject];
                cell.textLabel.text should contain(@"kCLErrorRegionMonitoringFailure");
            });
            
            it(@"should toggle the monitoring switch off", ^{
                subject.monitoringSwitch.on should be_falsy;
            });
        });
    });

});

SPEC_END
