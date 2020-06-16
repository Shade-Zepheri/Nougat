#import "NUANotificationShadeModuleViewController.h"
#import "NUANotificationShadePageContentProvider.h"
#import "NUATogglesContentView.h"
#import "NUAToggleInstancesProvider.h"

@interface NUATogglesModuleController : NUANotificationShadeModuleViewController <NUATogglesContentViewDelegate, NUAToggleInstancesProviderObserver>
@property (assign, nonatomic) CGFloat revealPercentage;
@property (strong, readonly, nonatomic) NUAToggleInstancesProvider *togglesProvider;

@end
