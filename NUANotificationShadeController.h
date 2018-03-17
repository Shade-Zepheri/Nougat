#import "NUANotificationShadeViewController.h"
#import <SpringBoard/SBIgnoredForAutorotationSecureWindow.h>
#import <SpringBoard/SBScreenEdgePanGestureRecognizer+Private.h>
#import <SpringBoard/SBSystemGestureRecognizerDelegate.h>

@interface NUANotificationShadeController : UIViewController <SBSystemGestureRecognizerDelegate, NUANotificationShadeViewControllerDelegate> {
    SBWindow *_window;
    SBScreenEdgePanGestureRecognizer *_presentationGestureRecognizer;
    NUANotificationShadeViewController *_viewController;
    BOOL _isPresenting;
    BOOL _isDismissing;
    BOOL _panHasGoneBelowTopEdge;
}

@property (getter=isVisible, readonly, nonatomic) BOOL visible;
@property (getter=isPresented, nonatomic) BOOL presented;
@property (getter=isAnimating, nonatomic) BOOL animating;

+ (void)notifyNotificationShade:(NSString *)message didActivate:(BOOL)activated;

+ (instancetype)defaultNotificationShade;

- (void)handleMenuButtonTap;

- (void)dismissAnimated:(BOOL)animated;
- (void)dismissAnimated:(BOOL)animated completely:(BOOL)completely;

// Not sure if should actually include
- (void)presentAnimated:(BOOL)animated;
- (void)presentAnimated:(BOOL)animated showQuickSettings:(BOOL)showSettings;

@end
