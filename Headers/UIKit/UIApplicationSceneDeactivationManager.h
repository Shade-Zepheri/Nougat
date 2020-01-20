#import "UIApplicationSceneDeactivationAssertion.h"

@interface UIApplicationSceneDeactivationManager : NSObject

- (UIApplicationSceneDeactivationAssertion *)newAssertionWithReason:(UIApplicationSceneDeactivationReason)reason;

@end