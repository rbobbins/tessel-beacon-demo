#import "WelcomeViewController.h"
#import "RegistrationViewController.h"
#import "TesselRegistrationRepository.h"
#import <AFNetworking/AFNetworking.h>

@interface WelcomeViewController ()
@property (weak, nonatomic) IBOutlet UILabel *explanatoryLabel;
@property (nonatomic) TesselRegistrationRepository *tesselRegistrationRepository;
@end

@implementation WelcomeViewController

- (instancetype)initWithTesselRegistrationRepository:(TesselRegistrationRepository *)tesselRegistrationRepository {
    self = [super init];
    if (self) {
        self.tesselRegistrationRepository = tesselRegistrationRepository;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Step 0: Welcome!";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Next"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(didTapNext:)];
    self.navigationItem.hidesBackButton = YES;
    
    NSMutableString *labelText = [[NSMutableString alloc] initWithString:@"This application demonstrates how to use your Tessel device as an iBeacon. It includes the following features:\n\n"];

    [labelText appendString:@"- Registering the iBeacon to a remote server\n\n"];
    [labelText appendString:@"- Notifications each time you enter or exit the region of the iBeacon, including when app is in the background\n\n"];
    [labelText appendString:@"- Logging to remote server each time this iPhone/iPad is within range of the iBeacon\n\n"];
    [labelText appendString:@"- Monitoring the distance to that iBecaon, only when app is in the foreground\n\n"];

    
    self.explanatoryLabel.text = labelText;
}

#pragma mark - Actions

- (void)didTapNext:(id)sender {
    RegistrationViewController *registrationViewController = [[RegistrationViewController alloc] initWithTesselRegistrationRepository:self.tesselRegistrationRepository];
    [self.navigationController pushViewController:registrationViewController animated:NO];
}

@end
