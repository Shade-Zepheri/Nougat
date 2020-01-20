#import <UIKit/UIApplicationSceneDeactivationReason.h>

@interface FBUIApplicationSceneDeactivationAssertion : NSObject

- (instancetype)initWithReason:(UIApplicationSceneDeactivationReason)reason;

- (void)acquire;
- (void)relinquish;

@end