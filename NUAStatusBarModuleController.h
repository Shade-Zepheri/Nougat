#import "NUANotificationShadeModuleViewController.h"
#import <SpringBoard/SBDateTimeOverrideObserver.h>

@interface NUAStatusBarModuleController : NUANotificationShadeModuleViewController <SBDateTimeOverrideObserver> {
    //Really just copying SBLockScreenDateViewController
    NSNumber *_timerToken;
    BOOL _disablesUpdates;
}

@end
