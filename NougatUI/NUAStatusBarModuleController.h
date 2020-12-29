#import "NUANotificationShadeModuleViewController.h"
#import "NUAPreciseTimerManager.h"

@interface NUAStatusBarModuleController : NUANotificationShadeModuleViewController <NUAPreciseTimerManagerObserver>
@property (strong, readonly, nonatomic) NUAPreciseTimerManager *timeManager;
@property (nonatomic) BOOL disablesUpdates;

@end
