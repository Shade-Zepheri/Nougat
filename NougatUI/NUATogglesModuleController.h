#import "NUANotificationShadeModuleViewController.h"
#import "NUANotificationShadePageContentProvider.h"
#import "NUATogglesContentView.h"

@interface NUATogglesModuleController : NUANotificationShadeModuleViewController <NUATogglesContentViewDelegate>
@property (assign, nonatomic) CGFloat revealPercentage;

@end
