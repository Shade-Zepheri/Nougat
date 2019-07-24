#import "NUANotificationShadeModuleViewController.h"
#import "NUANotificationShadePageContentProvider.h"
#import "NUASettingsContentView.h"
#import <SpringBoard/SpringBoard-Umbrella.h>

@interface NUASettingsModuleController : NUANotificationShadeModuleViewController <NUASettingsContentViewDelegate, SBDateTimeOverrideObserver> {
    NSNumber *_timerToken;
    BOOL _disablesUpdates;
}

@property (assign, nonatomic) CGFloat revealPercentage;

@end
