#import "NUANotificationShadeModuleViewController.h"
#import "NUANotificationShadePageContentProvider.h"

@interface NUATogglesModuleController : NUANotificationShadeModuleViewController <NUANotificationShadePageContentProvider>
@property (assign, nonatomic) CGFloat presentedHeight;

@end
