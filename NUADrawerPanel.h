#import <UIKit/UIKit.h>
#import "headers.h"

//TODO: make UIScrollView for more than one page of toggles?
@interface NUADrawerPanel : UIView {
    BKSDisplayBrightnessTransactionRef _brightnessTransaction;
}
@property (strong, nonatomic) UISlider *brightnessSlider;
@property (strong, nonatomic) NSMutableArray *toggleArray;
- (void)updateTintTo:(UIColor *)color;
- (void)updateSliderValue;
- (void)refreshTogglePanel;
@end
