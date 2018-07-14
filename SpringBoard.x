#import "NUANotificationShadeController.h"
#import "NUAPreferenceManager.h"

#pragma mark - Hooks

%hook SpringBoard

- (void)batteryStatusDidChange:(NSDictionary *)info {
    %orig;

    [[NSNotificationCenter defaultCenter] postNotificationName:@"NUABatteryStatusDidChangeNotification" object:nil userInfo:info];
}

%group iOS9

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
    %init;

    if (%c(SBHomeHardwareButtonActions)) {
        %init(iOS10);
    } else {
        %init(iOS9);
    }

    // Create our singleton
    [NUAPreferenceManager sharedSettings];

    // Register to tweak loads when springboard done launching
    NSNotificationCenter * __weak center = [NSNotificationCenter defaultCenter];
    id __block token = [center addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
        // Simply create singleton
        [NUANotificationShadeController defaultNotificationShade];

        // Deregister as only created once
        [center removeObserver:token];
    }];
}
