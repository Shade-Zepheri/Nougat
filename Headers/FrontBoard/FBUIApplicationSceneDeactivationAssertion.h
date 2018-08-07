@interface FBUIApplicationSceneDeactivationAssertion : NSObject

- (instancetype)initWithReason:(NSInteger)reason;

- (void)acquire;
- (void)relinquish;

@end