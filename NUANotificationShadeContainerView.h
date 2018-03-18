#import "NUAModulesContainerViewController.h"
#import <UIKit/UIView+Internal.h>
#import <UIKit/_UIBackdropView.h>

@interface NUANotificationShadeContainerView : UIView {
    _UIBackdropView *_backdropView;
}

@property (strong, nonatomic) UIView *drawerView;
@property (nonatomic) CGFloat presentedHeight;
@property (nonatomic) BOOL changingBrightness;

@end
