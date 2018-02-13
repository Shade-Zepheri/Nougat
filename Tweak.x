#import "NUANotificationShadeController.h"
#import "NUAPreferenceManager.h"

%hook SBUIController

- (BOOL)clickedMenuButton {
    [[NUANotificationShadeController defaultNotificationShade] dismissAnimated:YES];
    return %orig;
}

- (BOOL)handleHomeButtonSinglePressUp {
    [[NUANotificationShadeController defaultNotificationShade] dismissAnimated:YES];
    return %orig;
}

%end

static inline void initializeTweak(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    [NUANotificationShadeController defaultNotificationShade];
}

%ctor {
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &initializeTweak, CFSTR("SBSpringBoardDidLaunchNotification"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    [NUAPreferenceManager sharedSettings];
}
