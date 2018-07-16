#import <UIKit/UIKit.h>
#import "NUANotificationShadeContainerView.h"
#import "NUANotificationShadePageContainerViewController.h"

@class NUANotificationShadeViewController;

@protocol NUANotificationShadeViewControllerDelegate <NSObject>
@required

- (void)notificationShadeViewControllerWantsExpansion:(NUANotificationShadeViewController *)controller;
- (void)notificationShadeViewControllerWantsDismissal:(NUANotificationShadeViewController *)controller completely:(BOOL)completely;
- (void)notificationShadeViewController:(NUANotificationShadeViewController *)controller handlePan:(UIPanGestureRecognizer *)panGesture;
- (BOOL)notificationShadeViewController:(NUANotificationShadeViewController *)controller canHandleGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer;

@end

@interface NUANotificationShadeViewController : UIViewController <NUANotificationShadeContainerViewDelegate, NUANotificationShadePageContainerViewControllerDelegate, UIGestureRecognizerDelegate> {
    NUANotificationShadePageContainerViewController *_containerViewController;
    NUANotificationShadeContainerView *_containerView;
    UIPanGestureRecognizer *_panGesture;
}

@property (weak, nonatomic) id<NUANotificationShadeViewControllerDelegate> delegate;
@property (assign, nonatomic) CGFloat presentedHeight;

@end
