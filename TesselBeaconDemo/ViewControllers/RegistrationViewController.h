#import <UIKit/UIKit.h>

@class TesselRegistrationRepository;

@interface RegistrationViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *noButton;
@property (weak, nonatomic) IBOutlet UIButton *yesButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UILabel *explanatoryLabel;

- (instancetype)init __attribute((unavailable("use designated initializer instead")));
- (instancetype)initWithTesselRegistrationRepository:(TesselRegistrationRepository *)tesselRegistrationRepository;
@end
