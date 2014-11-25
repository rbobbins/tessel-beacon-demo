#import "RegistrationViewController.h"
#import "TesselRegistrationRepository.h"
#import "KSPromise.h"
#import "TesselInformationViewController.h"

@interface RegistrationViewController ()
- (IBAction)didTapYes:(id)sender;

@property (nonatomic) TesselRegistrationRepository *tesselRegistrationRepository;

@end


@implementation RegistrationViewController

- (instancetype)initWithTesselRegistrationRepository:(TesselRegistrationRepository *)tesselRegistrationRepository;
{
    self = [super init];
    if (self) {
        self.tesselRegistrationRepository = tesselRegistrationRepository;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.yesButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.title = @"Setup Your Tessel";
    self.navigationItem.hidesBackButton = YES;
    self.explanatoryLabel.text = @"To get started using your Tessel as an iBeacon, we'll request a UUID from the server. Your iPhone will search for the iBeacon with this UUID, and it will be automatically whitelisted for posting checkins to the server.";
}

#pragma mark - Actions

- (IBAction)didTapYes:(id)sender {
    [self.spinner startAnimating];
    [self.yesButton setTitle:nil forState:UIControlStateNormal];
    
    self.view.userInteractionEnabled = NO;
    KSPromise *promise = [self.tesselRegistrationRepository registerNewTessel];
    [promise then:^id(NSString *newTesselId) {
        [self.spinner stopAnimating];
        
        TesselInformationViewController *tesselInformationViewController = [[TesselInformationViewController alloc] initWithTesselRegistrationRepository:self.tesselRegistrationRepository];
        [self.navigationController pushViewController:tesselInformationViewController animated:NO];
        return nil;
    } error:^id(NSError *error) {
        self.view.userInteractionEnabled = YES;
        self.explanatoryLabel.text = @"An error has occurred. Would you like to try again?";
        [self.yesButton setTitle:@"Yes!" forState:UIControlStateNormal];
        [self.spinner stopAnimating];
        return nil;
    }];
}



@end
