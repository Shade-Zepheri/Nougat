#import "NUANotificationShadeController.h"
#import "NUAPreferenceManager.h"
#import "Macros.h"

#pragma mark - Hooks

%group iOS9
%hook SBUIController

- (BOOL)clickedMenuButton {
    [[NUANotificationShadeController defaultNotificationShade] handleMenuButtonTap];
    return %orig;
}

%end
%end

%group iOS10
%hook SBHomeHardwareButtonActions

- (void)performSinglePressUpActions {
    %orig;

    // Receive home button events where the rest of SB does
    [[NUANotificationShadeController defaultNotificationShade] handleMenuButtonTap];
}

%end
%end

#pragma mark - Notifications

static inline void initializeTweak(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    [NUANotificationShadeController defaultNotificationShade];
}

#pragma mark - Constructor

%ctor {
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &initializeTweak, CFSTR("SBSpringBoardDidLaunchNotification"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    [NUAPreferenceManager sharedSettings];

    if (%c(SBHomeHardwareButtonActions)) {
        %init(iOS10);
    } else {
        %init(iOS9);
    }
}
