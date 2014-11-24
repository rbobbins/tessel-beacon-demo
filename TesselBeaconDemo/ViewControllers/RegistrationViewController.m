#import "RegistrationViewController.h"
#import "TesselRegistrationRepository.h"
#import "KSPromise.h"
#import "TesselInformationViewController.h"

@interface RegistrationViewController ()
- (IBAction)didTapYes:(id)sender;
- (IBAction)didTapToContinue:(id)sender;

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
    self.title = @"Step 1: Register Tessel";
    self.navigationItem.hidesBackButton = YES;
    
    if ([self.tesselRegistrationRepository registeredTesselRegion]) {
        TesselInformationViewController *tesselInformationViewController = [[TesselInformationViewController alloc] initWithTesselRegistrationRepository:self.tesselRegistrationRepository];
        [self presentViewController:tesselInformationViewController animated:YES completion:^{
            [self didTapToContinue:nil];
        }];
    }
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
        [self presentViewController:tesselInformationViewController
                           animated:YES
                         completion:^{
            [self didTapToContinue:nil];
        }];
        return nil;
    } error:^id(NSError *error) {
        self.view.userInteractionEnabled = YES;
        self.explanatoryLabel.text = @"An error has occurred. Would you like to try again?";
        [self.yesButton setTitle:@"Yes!" forState:UIControlStateNormal];
        [self.spinner stopAnimating];
        return nil;
    }];
}

- (IBAction)didTapToContinue:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:NO];
}


@end
