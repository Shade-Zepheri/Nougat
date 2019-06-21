#import "NUAModulesContainerViewController.h"
#import "NUANotificationShadePanelView.h"

@interface NUANotificationShadeContainerView : UIView
@property (strong, readonly, nonatomic) UIVisualEffectView *darkeningView;
@property (assign, nonatomic) CGFloat presentedHeight;
@property (getter=isChangingBrightness, nonatomic) BOOL changingBrightness;

@end
