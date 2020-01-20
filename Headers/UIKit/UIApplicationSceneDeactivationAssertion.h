#import "UIApplicationSceneDeactivationReason.h"

@class UIApplicationSceneDeactivationManager;

@interface UIApplicationSceneDeactivationAssertion : NSObject
@property (weak, readonly, nonatomic) UIApplicationSceneDeactivationManager *manager;
@property (readonly, nonatomic) UIApplicationSceneDeactivationReason reason;

- (instancetype)initWithReason:(UIApplicationSceneDeactivationReason)reason manager:(UIApplicationSceneDeactivationManager *)manager;

- (void)acquire;
- (void)relinquish;

@end