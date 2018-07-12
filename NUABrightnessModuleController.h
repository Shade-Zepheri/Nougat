#import "NUANotificationShadeModuleViewController.h"
#import "NUANotificationShadePageContentProvider.h"
#import <BackBoardServices/BKSDisplayBrightness.h>

@interface NUABrightnessModuleController : NUANotificationShadeModuleViewController <NUANotificationShadePageContentProvider> {
    BKSDisplayBrightnessTransactionRef _brightnessTransaction;
}

@property (strong, readonly, nonatomic) UISlider *slider;
@property (assign, nonatomic) CGFloat presentedHeight;

@end
