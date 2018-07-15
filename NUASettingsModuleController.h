#import "NUANotificationShadeModuleViewController.h"
#import "NUANotificationShadePageContentProvider.h"

@interface NUASettingsModuleController : NUANotificationShadeModuleViewController <NUANotificationShadePageContentProvider> {
    NSNumber *_timerToken;
    BOOL _disablesUpdates;
}

@property (assign, nonatomic) CGFloat presentedHeight;

@end
