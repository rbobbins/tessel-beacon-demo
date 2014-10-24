//
//  MainViewController.m
//  TesselBluetoothDemo
//
//  Created by Rachel Bobbins on 9/30/14.
//  Copyright (c) 2014 Rachel Bobbins. All rights reserved.
//

#import "MainViewController.h"
#import "TesselBeaconManager.h"
#import <CoreLocation/CoreLocation.h>

static NSString *cellIdentifier = @"cellIdentifier";

@interface MainViewController () <UITableViewDataSource>

- (IBAction)didTapClear:(id)sender;
- (IBAction)didTapScanForBeacon:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) TesselBeaconManager *beaconManager;
@property (nonatomic) NSMutableArray *messages;
@property (nonatomic) NSDateFormatter *timestampFormatter;

@end

@implementation MainViewController

- (id)initWithBeaconManager:(TesselBeaconManager *)beaconManager {
    self = [super init];
    if (self) {
        self.beaconManager = beaconManager;
        [self.beaconManager registerDelegate:self];
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.timestampFormatter = [[NSDateFormatter alloc] init];
    self.timestampFormatter.dateFormat = @"HH:mm:ss.SSS";
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
    self.messages = [NSMutableArray array];

}

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    cell.textLabel.text = self.messages[indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:12.f];
    
    return cell;
}


#pragma mark <TesselBeaconDelegate>

- (void)didEnterTesselRange {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Bonjour!"
                                                                             message:@"You're near a Tessel"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *dismiss = [UIAlertAction actionWithTitle:@"OK"
                                                      style:UIAlertActionStyleCancel
                                                    handler:nil];
    [alertController addAction:dismiss];
    [self presentViewController:alertController animated:NO completion:nil];
    [self updateTableWithMessage:@"entered range of tessel beacon"];
}

- (void)didExitTesselRange {
    [self updateTableWithMessage:@"exited range of tessel beacon"];
}

- (void)didUpdateProximityToTessel:(CLProximity)proximity {
    NSString *distance;
    switch (proximity) {
        case CLProximityFar:        distance = @"FAR"; break;
        case CLProximityNear:       distance = @"NEAR"; break;
        case CLProximityImmediate:  distance = @"IMMEDIATE"; break;
        case CLProximityUnknown:    distance = @"unknown"; break;
    }
    NSString *message = [NSString stringWithFormat:@"proximity to tessel: %@", distance];
    [self updateTableWithMessage:message];
}

#pragma mark - Actions

- (IBAction)didTapClear:(id)sender {
    [self.messages removeAllObjects];
    [self.tableView reloadData];
}

- (IBAction)didTapScanForBeacon:(id)sender {
    [self.beaconManager searchForTesselBeacon];
    [self updateTableWithMessage:@"User tapped scan for beacon"];
}


#pragma mark - Private

- (void)updateTableWithMessage:(NSString *)message {
    NSString *timestamp = [self.timestampFormatter stringFromDate:[NSDate date]];
    NSString *completeMessage = [NSString stringWithFormat:@"%@ : %@", timestamp, message];
    [self.messages addObject:completeMessage];
    [self.tableView reloadData];
}
@end
