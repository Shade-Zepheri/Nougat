#import <UIKit/UIKit.h>
#import "NUANotificationShadeViewController.h"
#import <BaseBoard/BaseBoard.h>
#import <CoverSheet/CoverSheet.h>
#import <FrontBoard/FrontBoard.h>
#import <NougatServices/NougatServices.h>
#import <SpringBoard/SpringBoard-Umbrella.h>
#import <UIKit/UIKit+Private.h>

typedef NS_ENUM(NSInteger, NUANotificationShadeState) {
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

@property (strong, readonly, nonatomic) NUAPreferenceManager *preferences;
@property (nonatomic) NUANotificationShadeState state;

@property (strong, nonatomic) SBAsynchronousRenderingAssertion *asynchronousRenderingAssertion;
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
- (void)dismissAnimated:(BOOL)animated completion:(void(^)(void))completion;
- (void)presentAnimated:(BOOL)animated;

- (void)updateStatesForOverlayPresentation;
- (void)updateStatesForOverlayDismissal;

@end
