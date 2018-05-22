#import "NUAModulesContainerViewController.h"
#import "NUANotificationShadeContainerView.h"

@class NUANotificationShadeViewController;

@protocol NUANotificationShadeViewControllerDelegate <NSObject>
@required

- (void)notificationShadeViewControllerWantsDismissal:(NUANotificationShadeViewController *)controller;
- (void)notificationShadeViewController:(NUANotificationShadeViewController *)controller handlePan:(UIPanGestureRecognizer *)panGesture;
- (BOOL)notificationShadeViewController:(NUANotificationShadeViewController *)controller canHandleGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer;

@end

@interface NUANotificationShadeViewController : UIViewController <NUANotificationShadeContainerViewDelegate, UIGestureRecognizerDelegate> {
    NUAModulesContainerViewController *_modulesViewController;
    NUANotificationShadeContainerView *_containerView;
    UIPanGestureRecognizer *_panGesture;
}

@property (weak, nonatomic) id<NUANotificationShadeViewControllerDelegate> delegate;
@property (nonatomic) CGFloat presentedHeight;

@end
