#import "NUAAlertItem.h"
#import <NougatServices/NougatServices.h>
#import <NougatUI/NougatUI.h>
#import <SpringBoard/SpringBoard-Umbrella.h>
#import <UserNotificationsKit/UserNotificationsKit.h>
#import <UserNotificationsUIKit/UserNotificationsUIKit.h>
#import <UIKit/UIApplication+Private.h>
#import <UIKit/UIKit+Private.h>
#import <UIKit/UIStatusBar.h>
#import <UIKitHelpers.h>
#import <Macros.h>
#import <version.h>

NUAPreferenceManager *settings;
NUANotificationShadeController *notificationShade;

#pragma mark - Battery

%hook SpringBoard

- (void)batteryStatusDidChange:(NSDictionary *)info {
    %orig;

    [[NSNotificationCenter defaultCenter] postNotificationName:@"NUABatteryStatusDidChangeNotification" object:nil userInfo:info];
}

// iOS 11+
- (void)toggleSearchWithWillBeginHandler:(void(^)(void))beginHandler completionHandler:(void(^)(void))completionHandler {
    [notificationShade dismissAnimated:YES];

    %orig;
}

%end

#pragma mark - Dismissal

%hook SBHomeHardwareButtonActions

- (void)performSinglePressUpActions {
    if ([notificationShade handleMenuButtonTap]) {
        return;
    }

    %orig;
}

%end

// iOS 13
%hook SBMainWorkspace

- (void)transientOverlayPresentationManagerRequestsControlCenterDismissal:(id)presentationManager animated:(BOOL)animated {
    %orig;

    [notificationShade dismissAnimated:animated];
}

%end

// Siri
%hook SBAssistantController 

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

%hook SBDashBoardViewController

- (void)_presentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated completion:(void(^)(void))completion {
    %orig;

    if (!modalViewController) {
        return;
    }

    [notificationShade dismissAnimated:animated];
}

%end

#pragma mark - Gesture Inhibition

%hook SBControlCenterController

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    BOOL shouldBegin = %orig;
    if (!settings.enabled) {
        // Not enabled
        return shouldBegin;
    }

    // Don't begin gesture if presented
    BOOL nougatPresented = notificationShade.presented;
    return !nougatPresented && shouldBegin;
}

%end

%group PreCoverSheet
%hook SBNotificationCenterController

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    BOOL shouldBegin = %orig;
    SBScreenEdgePanGestureRecognizer *showSystemGestureRecognizer = [self valueForKey:@"_showSystemGestureRecognizer"];
    if (gestureRecognizer != showSystemGestureRecognizer || !settings.enabled) {
        return shouldBegin;
    }

    // Don't begin gesture if presented
    BOOL nougatPresented = notificationShade.presented;
    return !nougatPresented && shouldBegin;
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

    // Don't begin gesture if presented
    BOOL nougatPresented = notificationShade.presented;
    return !nougatPresented && shouldBegin;
}

%end

%hook SBFluidSwitcherGestureManager

- (BOOL)_shouldBeginBottomEdgePanGesture:(UIGestureRecognizer *)gestureRecognizer {
    // Inhibit for Nougat, only needed on iOS 12+
    BOOL shouldBegin = %orig;
    if (!settings.enabled) {
        // Only override present gesture
        return shouldBegin;
    }

    // Don't begin gesture if presented
    BOOL nougatPresented = notificationShade.presented;
    return !nougatPresented && shouldBegin;
}

%end

#pragma mark - Reveal Gesture

%hookf(NSString *, SBAnalyticsNameForSystemGestureType, SBSystemGestureType type) {
    // Gotta override this because Springboard
    if (type == SBSystemGestureTypeShowNougat) {
        return @"Nougat";
    } else {
        return %orig;
    }
}

%end

#pragma mark - Notification Retreval

%hook NCNotificationStore

- (BOOL)addNotificationRequest:(NCNotificationRequest *)request {
    BOOL orig = %orig;

    // Pass along to repository
    [[NUANotificationRepository defaultRepository] insertNotificationRequest:request forCoalescedNotification:nil];
    return orig;
}

- (BOOL)removeNotificationRequest:(NCNotificationRequest *)request {
    BOOL orig = %orig;

    // Pass along to repository
    [[NUANotificationRepository defaultRepository] removeNotificationRequest:request forCoalescedNotification:nil];
    return orig;
}

%end

#pragma mark - Notification Launching

%hook SBNotificationBannerDestination

%new
- (void)nua_executeAction:(NCNotificationAction *)action forNotificationRequest:(NCNotificationRequest *)request {
    // Simply add our helper here
    id<NCNotificationDestinationDelegate> delegate = ((SBNotificationBannerDestination *)self).delegate;
    if ([delegate respondsToSelector:@selector(destination:executeAction:forNotificationRequest:requestAuthentication:withParameters:completion:)]) {
        // iOS 11+
        [delegate destination:self executeAction:action forNotificationRequest:request requestAuthentication:YES withParameters:@{} completion:nil];
    } else {
        // iOS 10
        [delegate destination:self executeAction:action forNotificationRequest:request withParameters:@{} completion:nil];
    }
}

%end

#pragma mark - Constructor

%ctor {
    // %hookf stuffs
    MSImageRef springboardImage;
    if (IS_IOS_OR_NEWER(iOS_13_0)) {
        springboardImage = MSGetImageByName("/System/Library/PrivateFrameworks/SpringBoard.framework/SpringBoard");
    } else {
        springboardImage = MSGetImageByName("/System/Library/CoreServices/SpringBoard.app/SpringBoard");
    }    
    void *SBAnalyticsNameForSystemGestureType = MSFindSymbol(springboardImage, "_SBAnalyticsNameForSystemGestureType");

    // Init hooks
    if (%c(SBNotificationCenterController)) {
        %init(PreCoverSheet);
    } else {
        %init(CoverSheet);
    }

    // Init the rest
    %init(_ungrouped);

    // Register to tweak loads when springboard done launching
    NSNotificationCenter * __weak center = [NSNotificationCenter defaultCenter];
    id __block token = [center addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
        // Create our singletons
        settings = [NUAPreferenceManager sharedSettings];
        notificationShade = [NUANotificationShadeController defaultNotificationShade];

        // Deregister as only created once
        [center removeObserver:token];
    }];

    // Register to device unlock to prompt user
    id __block promptToken = [center addObserverForName:@"SBHomescreenIconsDidAppearNotification" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
        if (settings.firstTimeUser) {
            // Show prompt
            NUAAlertItem *alertItem = [NUAAlertItem userGuideAlertItem];
            [alertItem show];
        }

        // Deregister as only needed once
        [center removeObserver:promptToken];
    }];
}
