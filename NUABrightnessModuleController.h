#import <BackBoardServices/BKSDisplayBrightness.h>
#import <UIKit/UIKit.h>

@interface NUABrightnessModuleController : UIViewController {
    BKSDisplayBrightnessTransactionRef _brightnessTransaction;
}

@property (strong, readonly, nonatomic) UISlider *slider;

@end
