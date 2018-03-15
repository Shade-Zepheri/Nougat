#import "NUANotificationShadeController.h"
#import "NUAPreferenceManager.h"

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

void (^loadTweak)(NSNotification *) = ^(NSNotification *nsNotification) {
    // Simply create singleton
    [NUANotificationShadeController defaultNotificationShade];
};

#pragma mark - Constructor

%ctor {
    // Create our singleton
    [NUAPreferenceManager sharedSettings];

    // Register to tweak loads when springboard done launching
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:loadTweak];

    // Init hooks
    if (%c(SBHomeHardwareButtonActions)) {
        %init(iOS10);
    } else {
        %init(iOS9);
    }
}
