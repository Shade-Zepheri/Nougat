typedef NS_ENUM(NSInteger, UIApplicationSceneDeactivationReason) {
    UIApplicationSceneDeactivationReasonSystemGesture,
    UIApplicationSceneDeactivationReasonNotificationCenter,
    UIApplicationSceneDeactivationReasonControlCenter,
    UIApplicationSceneDeactivationReasonAppSwitcher,
    UIApplicationSceneDeactivationReasonSiri,
    UIApplicationSceneDeactivationReasonSystemAnimation,
    UIApplicationSceneDeactivationReasonInteractiveBanner,
    UIApplicationSceneDeactivationReasonSystemOverlay,
    UIApplicationSceneDeactivationReasonKeyboardSuppression
};

@interface FBUIApplicationSceneDeactivationAssertion : NSObject

- (instancetype)initWithReason:(UIApplicationSceneDeactivationReason)reason;

- (void)acquire;
- (void)relinquish;

@end