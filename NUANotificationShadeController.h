#import "NUANotificationShadeViewController.h"
#import <SpringBoard/SBIgnoredForAutorotationSecureWindow.h>
#import <SpringBoard/SBScreenEdgePanGestureRecognizer+Private.h>
#import <SpringBoard/SBSystemGestureRecognizerDelegate.h>

typedef NS_ENUM(NSUInteger, NUANotificationShadePresentedState) {
    NUANotificationShadePresentedStateNone,
    NUANotificationShadePresentedStateQuickToggles,
    NUANotificationShadePresentedStateMainPanel,
};

@interface NUANotificationShadeController : UIViewController <SBSystemGestureRecognizerDelegate, NUANotificationShadeViewControllerDelegate> {
    SBWindow *_window;
    SBScreenEdgePanGestureRecognizer *_presentationGestureRecognizer;
    NUANotificationShadeViewController *_viewController;
    BOOL _isPresenting;
    BOOL _isDismissing;
}

@property (nonatomic) NUANotificationShadePresentedState presentedState;
@property (getter=isVisible, readonly, nonatomic) BOOL visible;
@property (getter=isPresented, nonatomic) BOOL presented;
@property (getter=isAnimating, nonatomic) BOOL animating;

+ (void)notifyNotificationShade:(NSString *)message didActivate:(BOOL)activated;

+ (instancetype)defaultNotificationShade;

- (BOOL)handleMenuButtonTap;

- (void)dismissAnimated:(BOOL)animated;
- (void)dismissAnimated:(BOOL)animated completely:(BOOL)completely;

// Not sure if should actually include
- (void)presentAnimated:(BOOL)animated;
- (void)presentAnimated:(BOOL)animated showQuickSettings:(BOOL)showSettings;

@end
