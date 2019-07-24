#import "NUANotificationShadeModuleViewController.h"
#import <SpringBoard/SpringBoard-Umbrella.h>

@interface NUAStatusBarModuleController : NUANotificationShadeModuleViewController <SBDateTimeOverrideObserver> {
    //Really just copying SBLockScreenDateViewController
    NSNumber *_timerToken;
    BOOL _disablesUpdates;
}

@end
