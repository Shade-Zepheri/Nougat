#import "NUAAlertItem.h"
#import <NougatServices/NougatServices.h>
#import <NougatUI/NougatUI.h>
#import <SpringBoard/SpringBoard-Umbrella.h>
#import <UserNotificationsKit/UserNotificationsKit.h>
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
%hook SBTransientOverlayPresentationManager

- (void)performPresentationRequest:(SBTransientOverlayPresentationRequest *)presentationRequest {
    %orig;

    // Update window level and/or dismiss
    [notificationShade updateStatesForOverlayPresentation];

    if (presentationRequest.viewController.contentOpaque) {
        [notificationShade dismissAnimated:YES];
    }
} 

- (void)performDismissalRequest:(SBTransientOverlayDismissalRequest *)dismissalRequest {
    %orig;

    // Reset window level
    [notificationShade updateStatesForOverlayDismissal];
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

+ (BOOL)willDismissOverlaysForDismissOptions:(NSUInteger)dismissOptions {
    BOOL willDismissOverlays = %orig;
    if (!settings.enabled) {
        // Not enabled
        return willDismissOverlays;
    }

    // Make sure Nougat is included
    return notificationShade.presented || willDismissOverlays;
}

- (void)_startAnimation {
    %orig;

    // Dismiss Nougat if applicable
    if (notificationShade.presented) {
        [notificationShade dismissAnimated:YES];
    }
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

- (BOOL)allowShowTransitionSystemGesture {
    BOOL allowGesture = %orig;
    if (!settings.enabled) {
        // Not enabled
        return allowGesture;
    }

    // Don't begin gesture if presented
    BOOL nougatPresented = notificationShade.presented;
    return !nougatPresented && allowGesture;
}

%end

%group PreCoverSheet
%hook SBNotificationCenterController

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    BOOL shouldBegin = %orig;
    if (!settings.enabled) {
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
    if (!settings.enabled) {
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

%hook SBAnalyticsClientClass

- (void)emitEvent:(NSUInteger)event withPayload:(NSDictionary<NSString *, id> *)payload {
    // Block SB gesture analytics for Nougat
    if (event == 12) {
        // Gesture event
        NSNumber *gestureTypeWrapper = payload[@"kSBSAnalyticsSystemGestureType"];
        NSUInteger gestureType = gestureTypeWrapper.unsignedIntegerValue;
        if (gestureType == SBSystemGestureTypeShowNougat) {
            // Is Nougat, stop
            return;
        }
    }

    %orig;
}

%end
%end

#pragma mark - Notification Retreval

%hook NCNotificationDestinationsRegistry

- (NSMutableSet<id<NCNotificationDestination>> *)_destinationsForRequestDestinations:(NSSet<NSString *> *)requestDestinations inDestinationDict:(NSMutableDictionary<NSString *, id<NCNotificationDestination>> *)destinationDict {
    NSMutableSet<id<NCNotificationDestination>> *destinations = %orig;
    if (![requestDestinations containsObject:@"BulletinDestinationNotificationCenter"] || !destinationDict[@"BulletinDestinationNotificationShade"]) {
        // Doesn't apply, or we arent registered
        return destinations;
    }

    // Add ourselves
    id<NCNotificationDestination> notificationShadeDestination = destinationDict[@"BulletinDestinationNotificationShade"];
    [destinations addObject:notificationShadeDestination];
    return destinations;
}

- (NSMutableSet<NSString *> *)destinationIdentifiersForRequestDestinations:(NSSet<NSString *> *)requestDestinations {
    NSMutableSet<NSString *> *destinationIdentifiers = %orig;
    if (![requestDestinations containsObject:@"BulletinDestinationNotificationCenter"] || !self.activeDestinations[@"BulletinDestinationNotificationShade"]) {
        // Doesn't apply, or we arent active
        return destinationIdentifiers;
    }

    // Add ourselves
    [destinationIdentifiers addObject:@"BulletinDestinationNotificationShade"];
    return destinationIdentifiers;
}

%end

#pragma mark - Constructor

%ctor {
    // Init hooks
    if (%c(SBNotificationCenterController)) {
        %init(PreCoverSheet);
    } else {
        Class SBAnalyticsClass = %c(SBFAnalyticsClient) ?: %c(SBAnalyticsClient);
        %init(CoverSheet, SBAnalyticsClientClass = SBAnalyticsClass);
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
