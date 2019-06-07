#import <NougatServices/NougatServices.h>
#import <NougatUI/NougatUI.h>

#pragma mark - Battery

%hook SpringBoard

- (void)batteryStatusDidChange:(NSDictionary *)info {
    %orig;

    [[NSNotificationCenter defaultCenter] postNotificationName:@"NUABatteryStatusDidChangeNotification" object:nil userInfo:info];
}

#pragma mark - Dismissal

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

%hook SBAssistantController // Siri

- (void)_presentForMainScreenAnimated:(BOOL)animated completion:(id)completion {
    %orig;

    [[NUANotificationShadeController defaultNotificationShade] dismissAnimated:animated];
}

%end

%hook SBStarkRelockUIAlert

- (void)activate {
    %orig;

    [[NUANotificationShadeController defaultNotificationShade] dismissAnimated:YES];
    }

%end

%hook SBUIAnimationFadeAlertToRemoteAlert

- (void)_animationFinished {
    %orig;

    [[NUANotificationShadeController defaultNotificationShade] dismissAnimated:NO];   
}

%end

%hook SBDismissOverlaysAnimationController

- (void)_startAnimation  {
    %orig;

    [[NUANotificationShadeController defaultNotificationShade] dismissAnimated:YES];
}

%end

%group iOS10
%hook SBDashBoardViewController // iOS 10+

- (void)_presentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated completion:(id)completion {
    %orig;

    if (!modalViewController) {
        return;
    }

    [[NUANotificationShadeController defaultNotificationShade] dismissAnimated:animated];
}

%end
%end

}

%end

%hook SBDismissOverlaysAnimationController

- (void)_startAnimation  {
    %orig;

    [[NUANotificationShadeController defaultNotificationShade] dismissAnimated:YES];
}

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
