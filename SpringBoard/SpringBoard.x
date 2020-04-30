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

#pragma mark - Gesture 

%group PreCoverSheet
%hook SBNotificationCenterController

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    BOOL shouldBegin = %orig;
    if (!settings.enabled) {
        return shouldBegin;
    }

    // Manually override to only invoke on corners to prevent conflict with Nougat
    CGPoint location = [gestureRecognizer locationInView:nil];
    UIInterfaceOrientation currentOrientation = [(SpringBoard *)[UIApplication sharedApplication] activeInterfaceOrientation];
    CGPoint correctedLocation = NUAConvertPointFromOrientationToOrientation(location, UIInterfaceOrientationPortrait, currentOrientation);

    // Adjust width for orientation
    CGFloat currentScreenWidth = NUAGetScreenWidthForOrientation(currentOrientation);
    BOOL withinRegion = correctedLocation.x > ((currentScreenWidth * 2) / 3) || correctedLocation.x < (currentScreenWidth / 3);
    return withinRegion && shouldBegin;
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

    // Manually override to only show on "left" 1/3 or on "left" notch inset to prevent conflict with Nougat
    CGPoint location = [gestureRecognizer locationInView:nil];
    UIInterfaceOrientation currentOrientation = [(SpringBoard *)[UIApplication sharedApplication] activeInterfaceOrientation];
    CGPoint correctedLocation = NUAConvertPointFromOrientationToOrientation(location, UIInterfaceOrientationPortrait, currentOrientation);
    CGFloat currentScreenWidth = NUAGetScreenWidthForOrientation(currentOrientation);

    // Check if notched or not
    UIStatusBar *statusBar = [UIApplication sharedApplication].statusBar;
    if (statusBar && [statusBar isKindOfClass:%c(UIStatusBar_Modern)]) {
        // Use notch insets
        UIStatusBar_Modern *modernStatusBar = (UIStatusBar_Modern *)statusBar;
        CGRect leadingFrame = [modernStatusBar frameForPartWithIdentifier:@"fittingLeadingPartIdentifier"];

        // Check if within inset
        BOOL isRTL = [UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft;
        CGFloat maxLeadingX = isRTL ? (currentScreenWidth - (CGRectGetMaxX(leadingFrame) - CGRectGetMinX(leadingFrame))) : CGRectGetMaxX(leadingFrame);
        if (maxLeadingX > 5000.0) {
            // Screen recording and carplay both cause the leading frame to be infinite, fallback to 1/4
            maxLeadingX = isRTL ? ((currentScreenWidth * 3) / 4) : (currentScreenWidth / 4);
        }

        BOOL withinRespectiveInset = isRTL ? (correctedLocation.x > maxLeadingX) : (correctedLocation.x < maxLeadingX);
        return withinRespectiveInset && shouldBegin;
    } else {
        // Regular old frames if no notch
        BOOL withinRegion = correctedLocation.x > ((currentScreenWidth * 2) / 3) || correctedLocation.x < (currentScreenWidth / 3);
        return withinRegion && shouldBegin;
    }
}

%end
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
