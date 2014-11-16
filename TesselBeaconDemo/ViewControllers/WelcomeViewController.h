#import <UIKit/UIKit.h>

@class TesselRegistrationRepository;

@interface WelcomeViewController : UIViewController

@property (weak, nonatomic, readonly) UILabel *explanatoryLabel;
- (instancetype)init __attribute((unavailable("use designated initializer instead")));
- (instancetype)initWithTesselRegistrationRepository:(TesselRegistrationRepository *)tesselRegistrationRepository;

@end
