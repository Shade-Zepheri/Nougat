#import <UIKit/UIKit.h>
#import "NUADisplayLink.h"
#import "NUANotificationShadeViewController.h"
#import <BaseBoard/BSInvalidatable.h>
#import <FrontBoard/FBDisplayLayoutElement.h>
#import <FrontBoard/FBUIApplicationSceneDeactivationAssertion.h>
#import <SpringBoard/SBDashBoardExternalBehaviorProviding.h>
#import <SpringBoard/SBDashBoardExternalPresentationProviding.h>
#import <SpringBoard/SBIgnoredForAutorotationSecureWindow.h>
#import <SpringBoard/SBScreenEdgePanGestureRecognizer+Private.h>
#import <SpringBoard/SBSystemGestureRecognizerDelegate.h>

typedef NS_ENUM(NSUInteger, NUANotificationShadeState) {
    NUANotificationShadeStateDismissed,
    NUANotificationShadeStatePresented
};

@interface NUANotificationShadeController : UIViewController <SBSystemGestureRecognizerDelegate, NUANotificationShadeViewControllerDelegate, SBDashBoardExternalBehaviorProviding, SBDashBoardExternalPresentationProviding> {
    SBWindow *_window;
    SBScreenEdgePanGestureRecognizer *_presentationGestureRecognizer;
    NUANotificationShadeViewController *_viewController;
    FBUIApplicationSceneDeactivationAssertion *_resignActiveAssertion;
    BOOL _isPresenting;
    BOOL _isDismissing;
    CGPoint _initalTouchLocation;
    NUADisplayLink *_animationTimer;
}

@property (nonatomic) NUANotificationShadeState state;
@property (strong, nonatomic) id<BSInvalidatable> idleTimerDisableAssertion;
@property (strong, nonatomic) FBDisplayLayoutElement *displayLayoutElement;
@property (getter=isVisible, readonly, nonatomic) BOOL visible;
@property (getter=isPresented, nonatomic) BOOL presented;
@property (getter=isAnimating, nonatomic) BOOL animating;

+ (void)notifyNotificationShade:(NSString *)message didActivate:(BOOL)activated;

+ (instancetype)defaultNotificationShade;

- (BOOL)handleMenuButtonTap;

- (void)dismissAnimated:(BOOL)animated;
- (void)presentAnimated:(BOOL)animated;

@end
