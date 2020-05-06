@class SBMainDisplaySceneManager, UIApplicationSceneDeactivationManager;

@interface SBSceneManagerCoordinator : NSObject
@property (readonly, nonatomic) UIApplicationSceneDeactivationManager *sceneDeactivationManager;

+ (instancetype)sharedInstance;
+ (SBMainDisplaySceneManager *)mainDisplaySceneManager;

@end