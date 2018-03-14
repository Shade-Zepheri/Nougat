#import "NUAModulesContainerViewController.h"
#import <UIKit/UIView+Internal.h>
#import <UIKit/_UIBackdropView.h>

@interface NUANotificationShadeContainerView : UIView {
    _UIBackdropView *_backdropView;
}

@property (weak, nonatomic) UIView *drawerView;
@property (nonatomic) CGFloat revealPercentage;
@property (nonatomic) BOOL changingBrightness;

@end
