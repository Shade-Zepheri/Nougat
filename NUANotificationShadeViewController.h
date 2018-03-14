#import "NUAModulesContainerViewController.h"
#import "NUANotificationShadeContainerView.h"

@class NUANotificationShadeViewController;

@protocol NUANotificationShadeViewControllerDelegate <NSObject>
@required

- (void)notificationShadeViewControllerWantsDismissal:(NUANotificationShadeViewController *)controller;
- (BOOL)notificationShadeViewControllerShouldShowQuickToggles:(NUANotificationShadeViewController *)controller;
- (void)notificationShadeViewController:(NUANotificationShadeViewController *)controller handlePan:(UIPanGestureRecognizer *)panGesture;
- (BOOL)notificationShadeViewController:(NUANotificationShadeViewController *)controller canHandleGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer;

@end

@interface NUANotificationShadeViewController : UIViewController {
    NUAModulesContainerViewController *_modulesViewController;
    NUANotificationShadeContainerView *_containerView;
    UIPanGestureRecognizer *_panGesture;
}

@property (weak, nonatomic) id<NUANotificationShadeViewControllerDelegate> delegate;
@property (nonatomic) CGFloat revealPercentage;

@end
