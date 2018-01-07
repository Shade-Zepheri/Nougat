#import <UIKit/UIKit.h>
#import "headers.h"

@interface NUABrightnessSectionController : UIViewController {
    BKSDisplayBrightnessTransactionRef _brightnessTransaction;
}

@property (strong, readonly, nonatomic) UISlider *slider;

@end
