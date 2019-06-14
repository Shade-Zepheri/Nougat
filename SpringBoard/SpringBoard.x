#import <Macros.h>
#import <NougatServices/NougatServices.h>
#import <NougatUI/NougatUI.h>
#import <SpringBoard/SBCoverSheetSystemGesturesDelegate.h>
#import <SpringBoard/SBUIController.h>
#import <SpringBoard/SpringBoard+Private.h>
#import <UIKit/UIApplication+Private.h>
#import <UIKit/UIScreen+Internal.h>
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

CGPoint _adjustTouchLocationForActiveOrientation(CGPoint location) {
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

    // Manually override to only show on left 1/3 to prevent conflict with Nougat
    UIWindow *window = [[%c(SBUIController) sharedInstance] window];
    CGPoint location = [gestureRecognizer locationInView:window];
    CGPoint correctedLocation = _adjustTouchLocationForActiveOrientation(location);
    return (correctedLocation.x < (kScreenWidth / 3)) && shouldBegin;
}

%end
%end

%group CoverSheet
%hook SBCoverSheetSystemGesturesDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    BOOL shouldReceiveTouch = %orig;
    if (gestureRecognizer != self.presentGestureRecognizer || !settings.enabled) {
        // Only override present gesture
        return shouldReceiveTouch;
    }

    // Manually override to only show on left 1/3 or on left notch inset to prevent conflict with Nougat
    UIWindow *window = [[%c(SBUIController) sharedInstance] window];
    CGPoint location = [touch locationInView:window];
    CGPoint correctedLocation = _adjustTouchLocationForActiveOrientation(location);

    // Check if notched or not
    UIStatusBar *statusBar = [UIApplication sharedApplication].statusBar;
    if (statusBar && [statusBar isKindOfClass:%c(UIStatusBar_Modern)]) {
        // Use notch insets
        UIStatusBar_Modern *modernStatusBar = (UIStatusBar_Modern *)statusBar;
        CGRect leadingFrame = [modernStatusBar frameForPartWithIdentifier:@"fittingLeadingPartIdentifier"];

        CGFloat maxLeadingX = CGRectGetMaxX(leadingFrame);
        if (maxLeadingX > 5000.0) {
            // Screen recording and carplay both cause the leading frame to be infinite, fallback to 1/4
            maxLeadingX = kScreenWidth / 4;
        }

        return (correctedLocation.x < maxLeadingX) && shouldReceiveTouch;
    } else {
        // Regular old frames if no notch
        return (correctedLocation.x < (kScreenWidth / 3)) && shouldReceiveTouch;
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
