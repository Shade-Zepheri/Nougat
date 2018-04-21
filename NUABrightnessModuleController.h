#import <UIKit/UIKit.h>
#import <BackBoardServices/BKSDisplayBrightness.h>

@interface NUABrightnessModuleController : UIViewController {
    BKSDisplayBrightnessTransactionRef _brightnessTransaction;
}

@property (strong, readonly, nonatomic) UISlider *slider;

@end
