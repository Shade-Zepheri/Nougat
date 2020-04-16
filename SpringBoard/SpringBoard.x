#import "NUAAlertItem.h"
#import <NougatServices/NougatServices.h>
#import <NougatUI/NougatUI.h>
#import <SpringBoard/SpringBoard-Umbrella.h>
#import <UserNotificationsKit/UserNotificationsKit.h>
#import <UserNotificationsUIKit/UserNotificationsUIKit.h>
#import <UIKit/UIApplication+Private.h>
#import <UIKit/UIKit+Private.h>
#import <UIKit/UIStatusBar.h>
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

CGPoint adjustTouchLocationForActiveOrientation(CGPoint location) {
    // _UIWindowConvertPointFromOrientationToOrientation
    CGFloat rotatedX = 0.0;
    CGFloat rotatedY = 0.0;
    UIInterfaceOrientation orientation = [(SpringBoard *)[UIApplication sharedApplication] activeInterfaceOrientation];
    switch (orientation) {
        case UIInterfaceOrientationUnknown:
        case UIInterfaceOrientationPortrait: {
            rotatedX = location.x;
            rotatedY = location.y;
            break;
        }
        case UIInterfaceOrientationPortraitUpsideDown: {
            rotatedX = CGRectGetWidth([UIScreen mainScreen].bounds) - location.x;
            rotatedY = CGRectGetHeight([UIScreen mainScreen].bounds) - location.y;
            break;
        }
        case UIInterfaceOrientationLandscapeLeft: {
            rotatedX = CGRectGetHeight([UIScreen mainScreen]._referenceBounds) - location.y;
            rotatedY = location.x;
            break;
        }
        case UIInterfaceOrientationLandscapeRight: {
            rotatedX = location.y;
            rotatedY = CGRectGetWidth([UIScreen mainScreen]._referenceBounds) - location.x;
            break;
        }
    }

    return CGPointMake(rotatedX, rotatedY);
}

%group PreCoverSheet
%hook SBNotificationCenterController

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    BOOL shouldBegin = %orig;
    if (!settings.enabled) {
        return shouldBegin;
    }

    // Manually override to only show on "left" 1/3 to prevent conflict with Nougat
    UIWindow *window = [[%c(SBUIController) sharedInstance] window];
    CGPoint location = [gestureRecognizer locationInView:window];
    CGPoint correctedLocation = adjustTouchLocationForActiveOrientation(location);

    BOOL isRTL = [UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft;
    BOOL withinRegion = isRTL ? (correctedLocation.x > ((kScreenWidth * 2) / 3)) : (correctedLocation.x < (kScreenWidth / 3));
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
    UIWindow *window = [[%c(SBUIController) sharedInstance] window];
    CGPoint location = [gestureRecognizer locationInView:window];
    CGPoint correctedLocation = adjustTouchLocationForActiveOrientation(location);

    // Check if notched or not
    BOOL isRTL = [UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft;
    UIStatusBar *statusBar = [UIApplication sharedApplication].statusBar;
    if (statusBar && [statusBar isKindOfClass:%c(UIStatusBar_Modern)]) {
        // Use notch insets
        UIStatusBar_Modern *modernStatusBar = (UIStatusBar_Modern *)statusBar;
        CGRect leadingFrame = [modernStatusBar frameForPartWithIdentifier:@"fittingLeadingPartIdentifier"];

        // Check if within inset
        CGFloat maxLeadingX = isRTL ? (kScreenWidth - (CGRectGetMaxX(leadingFrame) - CGRectGetMinX(leadingFrame))) : CGRectGetMaxX(leadingFrame);
        if (maxLeadingX > 5000.0) {
            // Screen recording and carplay both cause the leading frame to be infinite, fallback to 1/4
            maxLeadingX = isRTL ? ((kScreenWidth * 3) / 4) : (kScreenWidth / 4);
        }

        BOOL withinRespectiveInset = isRTL ? (correctedLocation.x > maxLeadingX) : (correctedLocation.x < maxLeadingX);
        return withinRespectiveInset && shouldBegin;
    } else {
        // Regular old frames if no notch
        BOOL insideRegion = isRTL ? (correctedLocation.x > ((kScreenWidth * 2) / 3)) : (correctedLocation.x < (kScreenWidth / 3));
        return insideRegion && shouldBegin;
    }
}

%end
%end

#pragma mark - Notifications

%group Pre13CoverSheet
%hook NotificationListClass
// Hook into to manage notification stuffs

- (instancetype)init {
    self = %orig;
    if (self) {
        // Register for notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nua_executeAction:) name:@"NUANotificationLaunchNotification" object:nil];
    }

    return self;
}

- (void)dealloc {
    // Deregister notification
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NUANotificationLaunchNotification" object:nil];

    %orig;
}

#pragma mark - Actions

%new
- (void)nua_executeAction:(NSNotification *)notification {
    // Parse for info
    NSString *type = notification.userInfo[@"type"];
    NCNotificationRequest *request = notification.userInfo[@"request"];

    // Get action
    NCNotificationAction *action = nil;
    if ([type isEqualToString:@"default"]) {
        action = request.defaultAction;
    } else if ([type isEqualToString:@"clear"]) {
        action = request.clearAction;
    }

    if (!action) {
        // There was no action, return
        return;
    }

    // Manually call delegate methods
    id<NCNotificationListViewControllerDestinationDelegate> destinationDelegate = ((NCNotificationListViewController *)self).destinationDelegate;
    if ([destinationDelegate respondsToSelector:@selector(notificationListViewController:requestsExecuteAction:forNotificationRequest:withParameters:completion:)]) {
        // iOS 10
        [destinationDelegate notificationListViewController:self requestsExecuteAction:action forNotificationRequest:request withParameters:@{} completion:nil];
    } else {
        // iOS 11-12
        [destinationDelegate notificationListViewController:self requestsExecuteAction:action forNotificationRequest:request requestAuthentication:YES withParameters:@{} completion:nil];
    }
}

#pragma mark - Notification managements

- (BOOL)insertNotificationRequest:(NCNotificationRequest *)request forCoalescedNotification:(NCCoalescedNotification *)coalescedNotification {
    BOOL orig = %orig;

    // Pass along to repository
    [[NUANotificationRepository defaultRepository] insertNotificationRequest:request forCoalescedNotification:coalescedNotification];

    return orig;
}

- (void)removeNotificationRequest:(NCNotificationRequest *)request forCoalescedNotification:(NCCoalescedNotification *)coalescedNotification {
    // Pass along to repository
    [[NUANotificationRepository defaultRepository] removeNotificationRequest:request forCoalescedNotification:coalescedNotification];

    %orig;
}

%end
%end

// iOS 13 Notifications
%group iOS13CoverSheet
%hook NCNotificationStructuredListViewController

- (instancetype)init {
    self = %orig;
    if (self) {
        // Register for notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nua_executeAction:) name:@"NUANotificationLaunchNotification" object:nil];
    }

    return self;
}

- (void)dealloc {
    // Deregister notification
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NUANotificationLaunchNotification" object:nil];

    %orig;
}

#pragma mark - Actions

%new
- (void)nua_executeAction:(NSNotification *)notification {
    // Parse for info
    NSString *type = notification.userInfo[@"type"];
    NCNotificationRequest *request = notification.userInfo[@"request"];

    NCNotificationListCell *listCell = [self nua_notificationListCellForRequest:request];
    if ([type isEqualToString:@"default"]) {
        // Perform default action
        if (listCell) {
            // Execute from cell
            [listCell _executeDefaultAction];
        } else {
            // Manually call delegate methods
            NCNotificationStructuredSectionList *notificationSection = self.masterList.notificationSections.lastObject;
            NCNotificationGroupList *notificationGroup = notificationSection.notificationGroups.firstObject;
            [notificationGroup _performDefaultActionForNotificationRequest:request withCompletion:nil];
        }
    } else if ([type isEqualToString:@"clear"]) {
        // Perform clear action
        if (listCell) {
            // Execute from cell
            [listCell _executeClearAction];
        } else {
            // Call delegate methods manually
            NCNotificationStructuredSectionList *notificationSection = self.masterList.notificationSections.lastObject;
            NCNotificationGroupList *notificationGroup = notificationSection.notificationGroups.firstObject;
            [notificationGroup _clearNotificationRequest:request withCompletion:nil];
        }
    }
}

%new
- (NCNotificationListCell *)nua_notificationListCellForRequest:(NCNotificationRequest *)request {
    NCNotificationMasterList *masterList = self.masterList;
    for (NCNotificationStructuredSectionList *notificationSection in masterList.notificationSections) {
        for (NCNotificationGroupList *notificationGroup in notificationSection.notificationGroups) {
            NCNotificationListCell *listCell = [notificationGroup _currentCellForNotificationRequest:request];
            if (!listCell) {
                continue;
            }

            // Found the list cell
            return listCell;
        }
    }

    // return nothing by default
    return nil;
}

#pragma mark - Notification managements

- (void)insertNotificationRequest:(NCNotificationRequest *)request {
    %orig;

    // Pass along to repository
    [[NUANotificationRepository defaultRepository] insertNotificationRequest:request forCoalescedNotification:nil];
}

- (void)removeNotificationRequest:(NCNotificationRequest *)request {
    %orig;

    // Pass along to repository
    [[NUANotificationRepository defaultRepository] removeNotificationRequest:request forCoalescedNotification:nil];
}

%end
%end

#pragma mark - Constructor

%ctor {
    // Init hooks
    if (%c(SBNotificationCenterController)) {
        %init(PreCoverSheet);
    } else {
        %init(CoverSheet);
    }

    // Figure out notification hooks
    if (%c(NCNotificationStructuredListViewController)) {
        // iOS 13+
        %init(iOS13CoverSheet);
    } else {
        // iOS 12-
        Class listClass = %c(NCNotificationCombinedListViewController) ?: %c(NCNotificationSectionListViewController);
        %init(Pre13CoverSheet, NotificationListClass=listClass);
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
