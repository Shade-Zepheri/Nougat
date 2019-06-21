#import <UIKit/UIKit.h>
#import "NUANotificationShadeContainerView.h"
#import "NUANotificationShadePageContainerViewController.h"

@class NUANotificationShadeViewController;

@protocol NUANotificationShadeViewControllerDelegate <NSObject>
@required

- (void)notificationShadeViewControllerWantsExpansion:(NUANotificationShadeViewController *)controller;
- (void)notificationShadeViewControllerWantsDismissal:(NUANotificationShadeViewController *)controller completely:(BOOL)completely;
- (void)notificationShadeViewController:(NUANotificationShadeViewController *)controller handlePan:(UIPanGestureRecognizer *)panGestureRecognizer;
- (void)notificationShadeViewController:(NUANotificationShadeViewController *)controller handleTap:(UITapGestureRecognizer *)tapGestureRecognizer;
- (BOOL)notificationShadeViewController:(NUANotificationShadeViewController *)controller canHandleGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer;
- (CGFloat)notificationShadeViewControllerWantsFullyPresentedHeight:(NUANotificationShadeViewController *)controller;

@end

@interface NUANotificationShadeViewController : UIViewController <NUANotificationShadePageContainerViewControllerDelegate, UIGestureRecognizerDelegate> {
    NUANotificationShadePageContainerViewController *_containerViewController;
    NUANotificationShadeContainerView *_containerView;
    UIPanGestureRecognizer *_panGesture;
    UITapGestureRecognizer *_tapGesture;
}

@property (weak, nonatomic) id<NUANotificationShadeViewControllerDelegate> delegate;
@property (assign, nonatomic) CGFloat presentedHeight;

@end
