@class UIApplicationSceneDeactivationManager;

@interface SBSceneManagerCoordinator : NSObject
@property (readonly, nonatomic) UIApplicationSceneDeactivationManager *sceneDeactivationManager;

+ (instancetype)sharedInstance;

@end