#import <UIKit/UIKit.h>
#import "NUADisplayLink.h"
#import "NUANotificationShadeViewController.h"
#import <BaseBoard/BaseBoard.h>
#import <CoverSheet/CoverSheet.h>
#import <FrontBoard/FrontBoard.h>
#import <SpringBoard/SBIgnoredForAutorotationSecureWindow.h>
#import <SpringBoard/SpringBoard-Umbrella.h>
#import <UIKit/UIKit+Private.h>

typedef NS_ENUM(NSUInteger, NUANotificationShadeState) {
    NUANotificationShadeStateDismissed,
    NUANotificationShadeStatePresented
};

@interface NUANotificationShadeController : UIViewController <SBSystemGestureRecognizerDelegate, NUANotificationShadeViewControllerDelegate, SBDashBoardExternalBehaviorProviding, SBDashBoardExternalPresentationProviding, SBDashBoardExternalAppearanceProviding, CSExternalBehaviorProviding, CSExternalPresentationProviding, CSExternalAppearanceProviding> {
    SBWindow *_window;
    SBScreenEdgePanGestureRecognizer *_presentationGestureRecognizer;
    NUANotificationShadeViewController *_viewController;
    FBUIApplicationSceneDeactivationAssertion *_oldResignActiveAssertion;
    UIApplicationSceneDeactivationAssertion *_newResignActiveAssertion;
    BOOL _isPresenting;
    BOOL _isDismissing;
    CGPoint _initalTouchLocation;
}

@property (nonatomic) NUANotificationShadeState state;
@property (strong, nonatomic) id<BSInvalidatable> idleTimerDisableAssertion;
@property (strong, nonatomic) FBDisplayLayoutElement *displayLayoutElement;
@property (strong, nonatomic) SBDashBoardLayoutStrategy *layoutStrategy;
@property (getter=isVisible, readonly, nonatomic) BOOL visible;
@property (getter=isPresented, nonatomic) BOOL presented;
@property (getter=isAnimating, nonatomic) BOOL animating;

+ (void)notifyNotificationShade:(NSString *)message didActivate:(BOOL)activated;

+ (instancetype)defaultNotificationShade;

- (BOOL)handleMenuButtonTap;

- (void)dismissAnimated:(BOOL)animated;

@end
