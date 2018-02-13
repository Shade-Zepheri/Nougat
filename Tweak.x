#import "NUANotificationShadeController.h"
#import "NUAPreferenceManager.h"

%hook SBUIController
- (BOOL)clickedMenuButton {
    [[NUANotificationShadeController defaultNotifcationShade] dismissDrawer:YES];
    return %orig;
}

- (BOOL)handleHomeButtonSinglePressUp {
    [[NUANotificationShadeController defaultNotifcationShade] dismissDrawer:YES];
    return %orig;
}
%end

static inline void initializeTweak(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    [NUANotificationShadeController defaultNotifcationShade];
}

%ctor {
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &initializeTweak, CFSTR("SBSpringBoardDidLaunchNotification"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    [NUAPreferenceManager sharedSettings];
}
