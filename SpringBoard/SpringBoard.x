#import <Macros.h>
#import <NougatServices/NougatServices.h>
#import <NougatUI/NougatUI.h>
#import <SpringBoard/SBCoverSheetSystemGesturesDelegate.h>
#import <SpringBoard/SBUIController.h>
#import <UIKit/UIApplication+Private.h>
#import <UIKit/UIStatusBar.h>
#import <UIKit/UIStatusBar_Modern.h>

NUAPreferenceManager *settings;
NUANotificationShadeController *notificationShade;

#pragma mark - Battery

%hook SpringBoard

- (void)batteryStatusDidChange:(NSDictionary *)info {
    %orig;

    [[NSNotificationCenter defaultCenter] postNotificationName:@"NUABatteryStatusDidChangeNotification" object:nil userInfo:info];
}

#pragma mark - Dismissal

%group iOS9

- (void)_handleMenuButtonEvent {
    if ([notificationShade handleMenuButtonTap]) {
        return;
    }

    %orig;
}

%end
%end

%group iOS10
%hook SBHomeHardwareButtonActions

- (void)performSinglePressUpActions {
    if ([notificationShade handleMenuButtonTap]) {
        return;
    }

    %orig;
}

%end
%end

%hook SBAssistantController // Siri

- (void)_presentForMainScreenAnimated:(BOOL)animated completion:(id)completion {
    %orig;

    [notificationShade dismissAnimated:animated];
}

%end

%hook SBStarkRelockUIAlert

- (void)activate {
    %orig;

    [notificationShade dismissAnimated:YES];
}

%end

%hook SBUIAnimationFadeAlertToRemoteAlert

- (void)_animationFinished {
    %orig;

    [notificationShade dismissAnimated:NO];   
}

%end

%hook SBDismissOverlaysAnimationController

- (void)_startAnimation  {
    %orig;

    [notificationShade dismissAnimated:YES];
}

%end

%group iOS10
%hook SBDashBoardViewController // iOS 10+

- (void)_presentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated completion:(id)completion {
    %orig;

    if (!modalViewController) {
        return;
    }

    [notificationShade dismissAnimated:animated];
}

%end
%end

#pragma mark - Gesture 

%group PreCoverSheet
%hook SBNotificationCenterController

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    BOOL shouldBegin = %orig;
    if (!settings.enabled) {
        return shouldBegin;
    }

    // Manually override to only show on left 1/3 to prevent conflict with Nougat
    UIWindow *window = [[%c(SBUIController) sharedInstance] window];
    CGFloat xlocation = [gestureRecognizer locationInView:window].x;
    return xlocation < (kScreenWidth / 3) && shouldBegin;
}

%end
%end

%group CoverSheet
%hook SBCoverSheetSystemGesturesDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    BOOL shouldBegin = %orig;
    if (gestureRecognizer != self.presentGestureRecognizer || !settings.enabled) {
        // Only override present gesture
        return shouldBegin;
    }

    // Manually override to only show on left 1/3 or on left notch inset to prevent conflict with Nougat
    UIWindow *window = [[%c(SBUIController) sharedInstance] window];
    CGFloat xlocation = [gestureRecognizer locationInView:window].x;

    // Check if notched or not
    UIStatusBar *statusBar = [UIApplication sharedApplication].statusBar;
    if (statusBar && [statusBar isKindOfClass:%c(UIStatusBar_Modern)]) {
        // Use notch insets
        UIStatusBar_Modern *modernStatusBar = (UIStatusBar_Modern *)statusBar;
        CGRect leadingFrame = [modernStatusBar frameForPartWithIdentifier:@"fittingLeadingPartIdentifier"];

        return xlocation < CGRectGetMaxX(leadingFrame) && shouldBegin;
    } else {
        // Regular old frames if no notch
        return xlocation < (kScreenWidth / 3) && shouldBegin;
    }
}

%end
%end

#pragma mark - Constructor

%ctor {
    // Init hooks
    %init;

    if (%c(SBNotificationCenterController)) {
        %init(PreCoverSheet);
    } else {
        %init(CoverSheet);
    }

    if (%c(SBHomeHardwareButtonActions)) {
        %init(iOS10);
    } else {
        %init(iOS9);
    }

    // Create our singleton
    settings = [NUAPreferenceManager sharedSettings];

    // Register to tweak loads when springboard done launching
    NSNotificationCenter * __weak center = [NSNotificationCenter defaultCenter];
    id __block token = [center addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
        // Simply create singleton
        notificationShade = [NUANotificationShadeController defaultNotificationShade];

        // Deregister as only created once
        [center removeObserver:token];
    }];
}
