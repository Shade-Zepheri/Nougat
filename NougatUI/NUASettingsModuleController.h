#import "NUANotificationShadeModuleViewController.h"
#import "NUANotificationShadePageContentProvider.h"
#import "NUASettingsContentView.h"
#import <SpringBoard/SBDateTimeOverrideObserver.h>

@interface NUASettingsModuleController : NUANotificationShadeModuleViewController <NUASettingsContentViewDelegate, SBDateTimeOverrideObserver> {
    NSNumber *_timerToken;
    BOOL _disablesUpdates;
}

@property (assign, nonatomic) CGFloat presentedHeight;

@end
