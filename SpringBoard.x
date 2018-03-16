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

#pragma mark - Notifications

void (^createNotificationShade)(NSNotification *) = ^(NSNotification *notification) {
    // Simply create singleton
    [NUANotificationShadeController defaultNotificationShade];
};

#pragma mark - Constructor

%ctor {
    // Create our singleton
    [NUAPreferenceManager sharedSettings];

    // Register to tweak loads when springboard done launching
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:createNotificationShade];

    // Init hooks
    if (!%c(SBHomeHardwareButtonActions)) {
        %init(iOS9);
    }
}
