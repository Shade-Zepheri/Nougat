#import "NUANotificationShadeModuleViewController.h"
#import "NUAPreciseTimerManager.h"
#import <BatteryCenter/BatteryCenter.h>

@interface NUAStatusBarModuleController : NUANotificationShadeModuleViewController <BCBatteryDeviceObserving, NUAPreciseTimerManagerObserver>
@property (strong, readonly, nonatomic) NUAPreciseTimerManager *timeManager;
@property (nonatomic) BOOL disablesUpdates;

@end
