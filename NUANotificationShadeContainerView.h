#import "NUAModulesContainerViewController.h"
#import <UIKit/UIView+Internal.h>
#import <UIKit/_UIBackdropView.h>

@class NUANotificationShadeContainerView;

@protocol NUANotificationShadeContainerViewDelegate <NSObject>
@required

- (UIView *)notificationShadeForContainerView:(NUANotificationShadeContainerView *)containerView;

@end

@interface NUANotificationShadeContainerView : UIView {
    _UIBackdropView *_backdropView;
}

@property (weak, nonatomic) id<NUANotificationShadeContainerViewDelegate> delegate;
@property (nonatomic) CGFloat presentedHeight;
@property (nonatomic) BOOL changingBrightness;

@end
