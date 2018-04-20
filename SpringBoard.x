#import "NUANotificationShadeController.h"
#import "NUAPreferenceManager.h"

#pragma mark - Notifications

void (^createNotificationShade)(NSNotification *) = ^(NSNotification *notification) {
    // Simply create singleton
    [NUANotificationShadeController defaultNotificationShade];
};

#pragma mark - Hooks

%group iOS9
%hook SpringBoard

- (void)_handleMenuButtonEvent {
    if ([[NUANotificationShadeController defaultNotificationShade] handleMenuButtonTap]) {
        return;
    }

    %orig;
}

%end
%end

%group iOS10
%hook SBHomeHardwareButtonActions

- (void)performSinglePressUpActions {
    if ([[NUANotificationShadeController defaultNotificationShade] handleMenuButtonTap]) {
        return;
    }

    %orig;
}

%end
%end

#pragma mark - Constructor

%ctor {
    // Init hooks
    if (%c(SBHomeHardwareButtonActions)) {
        %init(iOS10);
    } else {
        %init(iOS9);
    }

    // Create our singleton
    [NUAPreferenceManager sharedSettings];

    // Register to tweak loads when springboard done launching
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:createNotificationShade];
}
