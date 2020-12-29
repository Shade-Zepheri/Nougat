#import "NUANotificationShadeModuleViewController.h"
#import "NUANotificationShadePageContentProvider.h"
#import "NUAPreciseTimerManager.h"
#import "NUASettingsContentView.h"

@interface NUASettingsModuleController : NUANotificationShadeModuleViewController <NUASettingsContentViewDelegate, NUAPreciseTimerManagerObserver>
@property (strong, readonly, nonatomic) NUAPreciseTimerManager *timeManager;
@property (assign, nonatomic) CGFloat revealPercentage;
@property (nonatomic) BOOL disablesUpdates;

@end
