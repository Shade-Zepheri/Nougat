#import <UIKit/UIKit.h>

//TODO: make UIScrollView for more than one page of toggles?
@interface NUADrawerPanel : UIView {
    BKSDisplayBrightnessTransactionRef _brightnessTransaction;
}
@property (strong, nonatomic) NSArray *togglesArray;
@property (strong, nonatomic) UISlider *brightnessSlider;
@end
