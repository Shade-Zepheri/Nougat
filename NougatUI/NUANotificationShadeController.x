#import "NUANotificationShadeController.h"
#import <SpringBoardHome/SpringBoardHome.h>
#import <SpringBoardServices/SpringBoardServices+Private.h>
#import <UIKit/UIApplication+Private.h>
#import <UIKit/UIStatusBar.h>
#import <Macros.h>
#import <math.h>
#import <UIKitHelpers.h>
#import <version.h>

@implementation NUANotificationShadeController

+ (void)notifyNotificationShade:(NSString *)message didActivate:(BOOL)activated {
    if (!message) {
        return;
    }

    // Determine if activated or not and send message
    NSString *notificationName = activated ? @"NUANotificationShadeDidActivate" : @"NUANotificationShadeDidDeactivate";
    NSDictionary *userInfo = @{@"NUANotificationShadeControlName" : message};

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:notificationName object:nil userInfo:userInfo];
}

+ (instancetype)defaultNotificationShade {
    static NUANotificationShadeController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });

    return sharedInstance;
}

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        // Set defaults
        _state = NUANotificationShadeStateDismissed;
        _preferences = [NUAPreferenceManager sharedSettings];

        // Registering for same notifications that NC does
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(_handleBacklightFadeFinished:) name:@"SBBacklightFadeFinishedNotification" object:nil];
        [center addObserver:self selector:@selector(_handleUIDidLock:) name:@"SBLockScreenUIDidLockNotification" object:nil];

        // Add LS stuff
        SBLockScreenManager *manager = [%c(SBLockScreenManager) sharedInstance];
        if ([manager respondsToSelector:@selector(dashBoardViewController)]) {
            // Only iOS 10+
            SBDashBoardViewController *dashBoardViewController = manager.dashBoardViewController;
            [dashBoardViewController registerExternalBehaviorProvider:self];
            [dashBoardViewController registerExternalPresentationProvider:self];

            if ([dashBoardViewController respondsToSelector:@selector(registerExternalAppearanceProvider)]) {
                // iOS 11+
                [dashBoardViewController registerExternalAppearanceProvider:self];
            }
        } else if ([manager respondsToSelector:@selector(coverSheetViewController)]) {
            // iOS 13
            CSCoverSheetViewController *coverSheetViewController = manager.coverSheetViewController;
            [coverSheetViewController registerExternalBehaviorProvider:self];
            [coverSheetViewController registerExternalPresentationProvider:self];
            [coverSheetViewController registerExternalAppearanceProvider:self];
        }

        _displayLayoutElement = [[FBDisplayLayoutElement alloc] initWithDisplayType:FBSDisplayTypeMain identifier:@"NUANotificationShade" elementClass:[SBSDisplayLayoutElement class]];

        // Create and add gesture
        _presentationGestureRecognizer = [[%c(SBScreenEdgePanGestureRecognizer) alloc] initWithTarget:self action:@selector(_handleShowNotificationShadeGesture:)];
        _presentationGestureRecognizer.edges = UIRectEdgeTop;
        if ([_presentationGestureRecognizer respondsToSelector:@selector(sb_setStylusTouchesAllowed:)]) {
            // Guard because removed in 13.4
            [_presentationGestureRecognizer sb_setStylusTouchesAllowed:NO];
        }
        _presentationGestureRecognizer.delegate = self;

        [[%c(SBSystemGestureManager) mainDisplayManager] addGestureRecognizer:_presentationGestureRecognizer withType:SBSystemGestureTypeShowNougat];

        [self _setupGestureFailRelationships];

        // Resign assertion
        SBSceneManagerCoordinator *sceneManagerCoordinator = [%c(SBSceneManagerCoordinator) sharedInstance];
        if ([manager respondsToSelector:@selector(sceneDeactivationManager)]) {
            // iOS 13
            UIApplicationSceneDeactivationManager *deactivationManager = sceneManagerCoordinator.sceneDeactivationManager;
            _newResignActiveAssertion = [deactivationManager newAssertionWithReason:UIApplicationSceneDeactivationReasonControlCenter];
        } else {
            // iOS 12
            _oldResignActiveAssertion = [[%c(FBUIApplicationSceneDeactivationAssertion) alloc] initWithReason:UIApplicationSceneDeactivationReasonControlCenter];
        }

        // CC calls this in init so we will too
        [self view];
    }

    return self;
}

- (void)dealloc {
    // Remove gesture recognizer
    [[%c(SBSystemGestureManager) mainDisplayManager] removeGestureRecognizer:_presentationGestureRecognizer];

    SBLockScreenManager *manager = [%c(SBLockScreenManager) sharedInstance];
    if ([manager respondsToSelector:@selector(dashBoardViewController)]) {
        // Only iOS 10+
        SBDashBoardViewController *dashBoardViewController = manager.dashBoardViewController;
        [dashBoardViewController unregisterExternalBehaviorProvider:self];
        [dashBoardViewController unregisterExternalPresentationProvider:self];
    } else if ([manager respondsToSelector:@selector(coverSheetViewController)]) {
        // iOS 13
        CSCoverSheetViewController *coverSheetViewController = manager.coverSheetViewController;
        [coverSheetViewController unregisterExternalBehaviorProvider:self];
        [coverSheetViewController unregisterExternalPresentationProvider:self];
    }

    // Relinquish assertion
    if (_newResignActiveAssertion) {
        // iOS 13
        [_newResignActiveAssertion relinquish];
    } else {
        // iOS 10-12
        [_oldResignActiveAssertion relinquish];
    }
}

#pragma mark - View management

- (void)loadView {
    [super loadView];

    // create view controller
    self.view.frame = [UIScreen mainScreen].bounds;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    _viewController = [[NUANotificationShadeViewController alloc] init];
    _viewController.delegate = self;
    [_viewController view];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (!_viewController.view.superview) {
        return;
    }

    [_viewController beginAppearanceTransition:YES animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    if (!_viewController.view.superview) {
        return;
    }

    [_viewController endAppearanceTransition];

    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    if (!_viewController.view.superview) {
        return;
    }

    [_viewController beginAppearanceTransition:NO animated:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    if (!_viewController.view.superview) {
        return;
    }

    [_viewController endAppearanceTransition];

    [super viewDidDisappear:animated];
}

#pragma mark - Properties

- (void)setPresented:(BOOL)presented {
    if (_presented == presented) {
        return;
    }

    _presented = presented;

    SBLockScreenManager *manager = [%c(SBLockScreenManager) sharedInstance];
    if ([manager respondsToSelector:@selector(dashBoardViewController)]) {
        // Only iOS 10+
        SBDashBoardViewController *dashBoardViewController = manager.dashBoardViewController;
        [dashBoardViewController externalPresentationProviderPresentationChanged:self];
    } else if ([manager respondsToSelector:@selector(coverSheetViewController)]) {
        CSCoverSheetViewController *coverSheetViewController = manager.coverSheetViewController;
        [coverSheetViewController externalPresentationProviderPresentationChanged:self];
    }
}

#pragma mark - UIViewController

- (BOOL)wantsFullScreenLayout {
    return YES;
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods {
    return NO;
}

- (BOOL)shouldAutomaticallyForwardRotationMethods {
    return YES;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (BOOL)_canShowWhileLocked {
    // New on iOS 13
    return YES;
}

#pragma mark Gesture Relationships

- (void)_setupGestureFailRelationships {
    // Coordinate with CoverSheet/NC
    if (%c(SBCoverSheetPresentationManager)) {
        // iOS 11-13
        SBCoverSheetPrimarySlidingViewController *coverSheetSlidingViewController = [[%c(SBCoverSheetPresentationManager) sharedInstance] coverSheetSlidingViewController];
        UIGestureRecognizer *edgePullGestureRecognizer = [coverSheetSlidingViewController.grabberTongue edgePullGestureRecognizer];
        [self _requirePresentGestureRecognizerToFailForGestureRecognizer:edgePullGestureRecognizer];
    } else {
        // iOS 10
        SBNotificationCenterController *notificationCenterController = [%c(SBNotificationCenterController) sharedInstance];
        SBScreenEdgePanGestureRecognizer *showSystemGestureRecognizer = [notificationCenterController valueForKey:@"_showSystemGestureRecognizer"];
        [self _requirePresentGestureRecognizerToFailForGestureRecognizer:showSystemGestureRecognizer];
    }

    // Coordinate with CC Gesture if applicable
    SBControlCenterController *controlCenterController = [%c(SBControlCenterController) sharedInstance];
    if ([controlCenterController respondsToSelector:@selector(statusBarPullGestureRecognizer)] && controlCenterController.statusBarPullGestureRecognizer) {
        UIPanGestureRecognizer *statusBarPullGestureRecognizer = controlCenterController.statusBarPullGestureRecognizer;
        [self _requireGestureRecognizerToFailForPresentGestureRecognizer:statusBarPullGestureRecognizer];
    }

    // Coordinate with Reachability if applicable
    SBReachabilityManager *reachabilityManager = [%c(SBReachabilityManager) sharedInstance];
    if ([reachabilityManager respondsToSelector:@selector(dismissPanGestureRecognizer)]) {
        // iOS 12-13
        UIPanGestureRecognizer *dismissPanGestureRecognizer = reachabilityManager.dismissPanGestureRecognizer;
        [self _requirePresentGestureRecognizerToFailForGestureRecognizer:dismissPanGestureRecognizer];
    }

    // Coordinate with PiP/Side Apps
    SBSystemGestureManager *gestureManager = [%c(SBSystemGestureManager) mainDisplayManager];
    if ([gestureManager respondsToSelector:@selector(gestureRecognizerOfType:shouldBeRequiredToFailByGestureRecognizer:)]) {
        // iOS 13+
        [gestureManager gestureRecognizerOfType:SBSystemGestureTypeUnpinSideApp shouldBeRequiredToFailByGestureRecognizer:_presentationGestureRecognizer];
        [gestureManager gestureRecognizerOfType:SBSystemGestureTypePinPiPApp shouldBeRequiredToFailByGestureRecognizer:_presentationGestureRecognizer];
    } else {
        SBMainDisplaySceneLayoutViewController *sceneLayoutViewController;
        if ([%c(SBSceneLayoutViewController) instancesRespondToSelector:@selector(mainDisplaySceneLayoutViewController)]) {
            // iOS 11-12
            sceneLayoutViewController = [%c(SBSceneLayoutViewController) mainDisplaySceneLayoutViewController];
            [sceneLayoutViewController _requireUnpinPanSystemGestureRecognizerFailureForGestureRecognizer:_presentationGestureRecognizer];
        } else {
            // iOS 10
            sceneLayoutViewController = [%c(SBSceneLayoutViewController) mainDisplayLayoutViewController];
            UIGestureRecognizer *sideSwitcherRevealGesture = [sceneLayoutViewController sideSwitcherRevealGesture];
            if (sideSwitcherRevealGesture) {
                [self _requireGestureRecognizerToFailForPresentGestureRecognizer:sideSwitcherRevealGesture];
            }
        }   
    }
}

- (void)_requirePresentGestureRecognizerToFailForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    // Have our gesture fail for other
    [gestureRecognizer requireGestureRecognizerToFail:_presentationGestureRecognizer];
}

- (void)_requireGestureRecognizerToFailForPresentGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    // Have other gesture fail for ours
    [_presentationGestureRecognizer requireGestureRecognizerToFail:gestureRecognizer];
}

#pragma mark - Reveal Gesture

- (UIView *)viewForSystemGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    // SBSystemGestureRecognizerDelegate
    return self.view;
}

- (BOOL)allowShowTransition {
    // Check Policy
    if ([[%c(SBLockStateAggregator) sharedInstance] hasAnyLockState]) {
        SBMainDisplaySceneManager *sceneManager = [%c(SBSceneManagerCoordinator) mainDisplaySceneManager];
        if ([sceneManager respondsToSelector:@selector(policyAggregator)]) {
            // iOS 11
            SBMainDisplayPolicyAggregator *policyAggregator = sceneManager.policyAggregator;
            BOOL allowCoverSheet = [policyAggregator allowsCapability:SBPolicyCapabilityCoverSheet];
            BOOL allowControlCenter = YES;
            if (%c(SBMainDisplayPolicyAggregator)) {
                // iOS 11+
                allowControlCenter = [policyAggregator allowsCapability:SBPolicyCapabilityControlCenter];
            } else {
                // iOS 10, different enum values
                allowControlCenter = [policyAggregator allowsCapability:(SBPolicyCapabilityControlCenter - 1)];
            }

            if (!allowCoverSheet || !allowControlCenter) {
                // Not allowed by policy
                return NO;
            }
        }
    }

    // Check for Banners
    if ([[%c(SBBannerController) sharedInstance] isShowingModalBanner]) {
        // Don't show if banner
        return NO;
    }

    // Check if LS suppresses CC if applicable
    SBLockScreenManager *lockScreenManager = [%c(SBLockScreenManager) sharedInstance];
    if ([lockScreenManager respondsToSelector:@selector(lockScreenEnvironment)] && lockScreenManager.isUILocked) {
        // iOS 13
        id<SBLockScreenEnvironment> lockScreenEnvironment = lockScreenManager.lockScreenEnvironment;
        id<SBLockScreenBehaviorSuppressing> behaviorSuppressor = lockScreenEnvironment.behaviorSuppressor;
        if ([behaviorSuppressor suppressesControlCenter]) {
            // Lockscreen suppresses CC
            return NO;
        }
    }

    // Check if overlay suppresses
    SBMainWorkspace *mainWorkspace = [%c(SBWorkspace) mainWorkspace];
    if ([mainWorkspace respondsToSelector:@selector(transientOverlayPresentationManager)]) {
        // iOS 13
        SBTransientOverlayPresentationManager *transientOverlayPresentationManager = mainWorkspace.transientOverlayPresentationManager;
        if (transientOverlayPresentationManager.shouldDisableControlCenter || transientOverlayPresentationManager.shouldDisableCoverSheet) {
            // Overlay prevents either CC or Coversheet, so we shall disable too
            return NO;
        }
    }

    // Check CC status
    SBControlCenterController *controlCenterController = [%c(SBControlCenterController) sharedInstance];
    if ([controlCenterController respondsToSelector:@selector(allowGestureForContentBelow)]) {
        if (!controlCenterController.allowGestureForContentBelow) {
            // CC is viisble
            return NO;
        }
    } else if (controlCenterController.visible) {
        // Don't show if visible
        return NO;
    }

    // Check old NC status
    if (%c(SBNotificationCenterController)) {
        // iOS 10
        if ([[%c(SBNotificationCenterController) sharedInstance] isVisible]) {
            // Old NC is visible, don't show
            return NO;
        }
    }

    // Otherwise, allowed
    return YES;
}

- (BOOL)allowShowTransitionSystemGesture {
    BOOL isDismissedOrDismissing = _isDismissing || !self.presented;
    if (isDismissedOrDismissing) {
        // Check if allowed
        return [self allowShowTransition];
    }

    // Otherwise, not allowed
    return NO;
}

- (BOOL)_shouldAllowNotificationShadeGesture {
    if (!self.preferences.enabled) {
        // Tweak isn't enabled
        return NO;
    }

    SBSystemGestureManager *gestureManager = [%c(SBSystemGestureManager) mainDisplayManager];
    if (![gestureManager isGestureWithTypeAllowed:SBSystemGestureTypeShowNougat]) {
        // System gesture is straight up not allowed
        return NO;
    }

    if (![self allowShowTransitionSystemGesture]) {
        // Notification shade isn't allowed
        return NO;
    }

    // Otherwise, allowed
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (![self _shouldAllowNotificationShadeGesture]) {
        // Gesture not allowed
        return NO;
    }

    // TODO: Add more criteria
    // Otherwise, allowed
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // Get location of touch
    CGPoint location = [self _locationOfTouchInActiveInterfaceOrientation:touch gestureRecognizer:gestureRecognizer];

    // Only start if within the notch and CC isnt present
    return [self _isLocationXWithinNotchRegion:location];
}

- (CGPoint)_locationOfTouchInActiveInterfaceOrientation:(UITouch *)touch gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    // Adjust for orientation
    CGPoint location = [touch locationInView:nil];
    UIInterfaceOrientation currentOrientation = [(SpringBoard *)[UIApplication sharedApplication] activeInterfaceOrientation];
    CGRect portraitBounds = NUAScreenBoundsAdjustedForOrientation(UIInterfaceOrientationPortrait);
    return NUAConvertPointFromOrientationToOrientation(location, portraitBounds.size, UIInterfaceOrientationPortrait, currentOrientation);
}

- (BOOL)_isLocationXWithinNotchRegion:(CGPoint)location {
    // Get proper width
    UIInterfaceOrientation currentOrientation = [(SpringBoard *)[UIApplication sharedApplication] activeInterfaceOrientation];
    CGFloat currentScreenWidth = NUAGetScreenWidthForOrientation(currentOrientation);

    UIStatusBar *statusBar = [UIApplication sharedApplication].statusBar;
    if (statusBar && [statusBar isKindOfClass:%c(UIStatusBar_Modern)]) {
        // Use notch insets
        UIStatusBar_Modern *modernStatusBar = (UIStatusBar_Modern *)statusBar;
        CGRect leadingFrame = [modernStatusBar frameForPartWithIdentifier:@"fittingLeadingPartIdentifier"];
        CGRect trailingFrame = [modernStatusBar frameForPartWithIdentifier:@"fittingTrailingPartIdentifier"];

        // Check if within "left"
        BOOL isRTL = [UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft;
        CGFloat maxLeadingX = isRTL ? (currentScreenWidth - (CGRectGetMaxX(leadingFrame) - CGRectGetMinX(leadingFrame))) : CGRectGetMaxX(leadingFrame);
        if (maxLeadingX > 5000.0) {
            // Screen recording and carplay both cause the leading frame to be infinite, fallback to 1/4
            // Also now on iOS 13, default statusbar is modern, and on non notch devices, rect is infinite
            maxLeadingX = isRTL ? ((currentScreenWidth * 3) / 4) : (currentScreenWidth / 4);
        }

        BOOL outsideLeftInset = isRTL ? (location.x < maxLeadingX) : (location.x > maxLeadingX);

        // Check if within "right"
        CGFloat minTrailingX = isRTL ? CGRectGetMaxX(trailingFrame) : (currentScreenWidth - (CGRectGetMaxX(trailingFrame) - CGRectGetMinX(trailingFrame)));
        if (isnan(minTrailingX)) {
            // Also now on iOS 13, default statusbar is modern, and on non notch devices, rect is infinite, so results in nan
            // Fall back to 1/4
            minTrailingX = currentScreenWidth - maxLeadingX;
        }

        BOOL outsideRightInset = isRTL ? (location.x > minTrailingX) : (location.x < minTrailingX);
        return outsideLeftInset && outsideRightInset;
    } else {
        // Regular old frames
        return location.x > (currentScreenWidth / 3) && location.x < (currentScreenWidth * 2 / 3);
    }
}

- (void)_handleShowNotificationShadeGesture:(SBScreenEdgePanGestureRecognizer *)gestureRecognizer {
    // Stealing stuff from SB's implementation of CC and NC and mashing them into a CCNC
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStatePossible:
            break;
        case UIGestureRecognizerStateBegan:
            [self _showNotificationShadeGestureBeganWithGestureRecognizer:gestureRecognizer];
            break;
        case UIGestureRecognizerStateChanged:
            [self _showNotificationShadeGestureChangedWithGestureRecognizer:gestureRecognizer];
            break;
        case UIGestureRecognizerStateEnded:
            [self _showNotificationShadeGestureEndedWithGestureRecognizer:gestureRecognizer];
            break;
        case UIGestureRecognizerStateCancelled:
            [self _showNotificationShadeGestureCancelled];
            break;
        case UIGestureRecognizerStateFailed:
            [self _showNotificationShadeGestureFailed];
            break;
    }
}

- (void)_showNotificationShadeGestureBeganWithGestureRecognizer:(SBScreenEdgePanGestureRecognizer *)gestureRecognizer {
    // Disable icon editing
    SBIconController *iconController = [%c(SBIconController) sharedInstance];
    if ([iconController respondsToSelector:@selector(setIsEditing:)]) {
        // iOS 10-12
        [iconController setIsEditing:NO];
    } else {
        // iOS 13
        SBRootFolderController *rootFolderController = iconController.rootFolderController;
        [rootFolderController setEditing:NO animated:YES];
    }

    // Begin presentation
    [self _beginAnimationWithGestureRecognizer:gestureRecognizer];
}

- (void)_beginAnimationWithGestureRecognizer:(SBScreenEdgePanGestureRecognizer *)gestureRecognizer {
    // Create view
    [self _setupViewForPresentation];

    // Begin presentation
    CGPoint location = [gestureRecognizer locationInView:self.view];
    [self beginAnimationWithLocation:location];
}

- (void)_showNotificationShadeGestureChangedWithGestureRecognizer:(SBScreenEdgePanGestureRecognizer *)gestureRecognizer {
    // Present in case not already
    if (!self.visible) {
        [self _beginAnimationWithGestureRecognizer:gestureRecognizer];
    }

    // Defer hard stuffs
    CGPoint location = [gestureRecognizer locationInView:self.view];
    [self updateAnimationWithLocation:location];
}

- (void)_showNotificationShadeGestureEndedWithGestureRecognizer:(SBScreenEdgePanGestureRecognizer *)gestureRecognizer {
    // Defer
    CGPoint location = [gestureRecognizer locationInView:self.view];
    CGPoint velocity = [gestureRecognizer velocityInView:self.view];
    [self endAnimationWithVelocity:velocity location:location wasCancelled:NO completion:^{
        [self _endAnimation];
    }];
}

- (void)_showNotificationShadeGestureCancelled {
    [self _showNotificationShadeGestureFailed];
}

- (void)_showNotificationShadeGestureFailed {
    // Cancel transition
    [self _cancelAnimation];
}

#pragma mark - Notification Shade Delegate

- (void)notificationShadeViewControllerWantsDismissal:(NUANotificationShadeViewController *)notificationShadeViewController {
    [self dismissAnimated:YES];
}

- (void)notificationShadeViewController:(NUANotificationShadeViewController *)notificationShadeViewController handlePan:(UIPanGestureRecognizer *)panGestureRecognizer {
    // Defer to use presentation methods (Note handles expanding further and dismissing)
    switch (panGestureRecognizer.state) {
        case UIGestureRecognizerStatePossible:
            break;
        case UIGestureRecognizerStateBegan: {
            CGPoint location = [panGestureRecognizer locationInView:self.view];
            [self beginAnimationWithLocation:location];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint location = [panGestureRecognizer locationInView:self.view];
            [self updateAnimationWithLocation:location];
            break;
        }
        case UIGestureRecognizerStateEnded: {
            CGPoint location = [panGestureRecognizer locationInView:self.view];
            CGPoint velocity = [panGestureRecognizer velocityInView:self.view];
            [self endAnimationWithVelocity:velocity location:location wasCancelled:NO completion:nil];
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed: {
            // Handle cancel
            [self _cancelAnimation];
            break;
        }
    }
}

- (void)notificationShadeViewController:(NUANotificationShadeViewController *)notificationShadeViewController handleTap:(UITapGestureRecognizer *)tapGestureRecognizer {
    [self dismissAnimated:YES];
}

- (BOOL)notificationShadeViewController:(NUANotificationShadeViewController *)notificationShadeViewController canHandleGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    // TODO Fix this
    return ((_presentationGestureRecognizer.state == UIGestureRecognizerStateBegan) ? NO : (_presentationGestureRecognizer.state != UIGestureRecognizerStateChanged)) && !self.animating;
}

- (NUAPreferenceManager *)preferencesForNotificationShadeViewController:(NUANotificationShadeViewController *)notificationShadeViewController {
    return self.preferences;
}

#pragma mark - Dashboard participating

- (NSString *)dashBoardIdentifier {
    return NSStringFromClass(self.class);
}

- (NSString *)coverSheetIdentifier {
    return [self dashBoardIdentifier];
}

- (NSInteger)participantState {
    return self.visible ? 2 : 1;
}

#pragma mark - Behavior providing

- (NSInteger)scrollingStrategy {
    return IS_IOS_OR_NEWER(iOS_11_0) ? 0 : 3;
}

- (NSInteger)notificationBehavior {
    return 0;
}

- (NSUInteger)restrictedCapabilities {
    return 0;
}

- (NSInteger)idleWarnMode {
    return 0;
}

- (NSInteger)idleTimerMode {
    return 1;
}

- (NSInteger)idleTimerDuration {
    return 6;
}

- (NSInteger)proximityDetectionMode {
    return 0;
}

#pragma mark - Presentation providing

- (id<UICoordinateSpace>)presentationCoordinateSpace {
    return self.view;
}

- (NSArray *)presentationRegions {
    if (self.presented) {
        if (%c(CSRegion)) {
            // iOS 13
            CSRegion *region = [%c(CSRegion) regionForCoordinateSpace:self.view];
            region = [region role:CSRegionRoleOverlay];
            return @[region];
        } else {
            // iOS 10-12
            SBDashBoardRegion *region = [%c(SBDashBoardRegion) regionForCoordinateSpace:self.view];
            region = [region role:SBDashBoardRegionRoleOverlay];
            return @[region];
        }
    }

    return nil;
}

#pragma mark - Appearance providing

- (NSString *)appearanceIdentifier {
    return [self coverSheetIdentifier];
}

- (NSInteger)backgroundStyle {
    return 0;
}

- (NSSet *)components {
    NSMutableSet *components = [NSMutableSet set];
    if (self.presented) {
        if (%c(CSComponent)) {
            // iOS 13
            CSComponent *component = [%c(CSComponent) homeAffordance];
            component = [component identifier:[self appearanceIdentifier]];
            component = [component priority:1];
            component = [component value:@(YES)];

            [components addObject:component];
        } else {
            // iOS 10-12
            SBDashBoardComponent *component = [%c(SBDashBoardComponent) homeAffordance];
            component = [component identifier:[self appearanceIdentifier]];
            component = [component priority:1];
            component = [component value:@(YES)];

            [components addObject:component];
        }
    } 

    return [components copy];
}

- (_UILegibilitySettings *)legibilitySettings {
    return nil;
}

- (UIColor *)backgroundColor {
    return nil;
}

#pragma mark - Notifications

- (void)_handleBacklightFadeFinished:(NSNotification *)notification {
    // Dismiss if screen is turned off
    BOOL screenIsOn = ((SBBacklightController *)[%c(SBBacklightController) sharedInstance]).screenIsOn;

    if (!screenIsOn) {
        [self dismissAnimated:NO];
    }
}

- (void)_handleUIDidLock:(NSNotification *)notification {
    // Dismiss if screen is turned off
    BOOL screenIsOn = ((SBBacklightController *)[%c(SBBacklightController) sharedInstance]).screenIsOn;

    if (screenIsOn) {
        [self dismissAnimated:YES];
    }
}

- (BOOL)handleMenuButtonTap {
    if (!self.visible) {
        return NO;
    }

    // Dismiss drawer for home button tap
    [self dismissAnimated:YES];
    return YES;
}

#pragma mark - Presentation

- (void)dismissAnimated:(BOOL)animated {
    // Dismiss completely
    if (!self.presented) {
        return;
    }

    // Animate out
    self.animating = YES;
    self.state = NUANotificationShadeStateDismissed;

    // Pass to view controller
    __weak __typeof(self) weakSelf = self;
    [_viewController dismissAnimated:animated completion:^{
        [weakSelf _finishAnimationWithCompletion:nil];
    }];
}

- (void)presentAnimated:(BOOL)animated {
    // Show quick settings
    if (self.state == NUANotificationShadeStatePresented) {
        return;
    }

    [self _beginPresentation];

    self.animating = YES;
    self.state = NUANotificationShadeStatePresented;

    // Animate in
    CGFloat height = [self _yValueForPresented];
    if (animated) {
        __weak __typeof(self) weakSelf = self;
        [_viewController updateToFinalPresentedHeight:height completion:^{
            [weakSelf _finishAnimationWithCompletion:nil];
        }];
    } else {
        [self _updatePresentedHeight:height];
        [self _finishAnimationWithCompletion:nil];
    }
}

#pragma mark - Second stage animation helpers

- (void)beginAnimationWithLocation:(CGPoint)location {
    // Set if is presenting or dismissing
    _isPresenting = !self.presented;
    _isDismissing = self.presented;

    // Setup view controller
    [self _prepareForPresentation];

    _initalTouchLocation = location;

    // Slide to height of touch location
    if (_isPresenting) {
        [UIView animateWithDuration:0.2 animations:^{
            // Touch location is the height
            CGFloat height = [self _notificationShadeHeightForLocation:location initalLocation:_initalTouchLocation];
            [self _presentViewToHeight:height];
        }];
    }
}

- (void)updateAnimationWithLocation:(CGPoint)location {
    // Make sure visible before continue
    if (!self.presented || !self.visible) {
        return;
    }

    // Calculate height and reveal to it
    CGFloat height = [self _notificationShadeHeightForLocation:location initalLocation:_initalTouchLocation];
    [self _presentViewToHeight:height];
}

- (void)endAnimationWithVelocity:(CGPoint)velocity location:(CGPoint)location wasCancelled:(BOOL)cancelled completion:(void(^)(void))completion {
    // Use project to calculate final position and check if within percent of targeted height
    if (self.presented && self.visible && self.animating) {
        CGFloat projectedY = location.y + [self project:velocity.y decelerationRate:0.998];
        if (_isPresenting) {
            // Check if within range to present
            CGFloat targetY = [self _yValueForPresented] * 0.85;
            self.state = (projectedY >= targetY) ? NUANotificationShadeStatePresented : NUANotificationShadeStateDismissed;
        } else {
            CGFloat targetY = [self _yValueForPresented] * 0.85;
            self.state = (projectedY <= targetY) ? NUANotificationShadeStateDismissed : NUANotificationShadeStatePresented;
        }

        // Animate to finished height
        CGFloat height = (self.state == NUANotificationShadeStatePresented) ? [self _yValueForPresented] : [self _yValueForDismissed];

        __weak __typeof(self) weakSelf = self;
        [_viewController updateToFinalPresentedHeight:height completion:^{
            [weakSelf _finishAnimationWithCompletion:completion];
        }];

    } else if (completion) {
        completion();
    }

    // Reset ivars
    [self _resetPanGestureStates];
}

#pragma mark - Convenience methods

- (BOOL)isVisible {
    return _window ? !_window.hidden : NO;
}

- (CGFloat)_yValueForDismissed {
    // Do we really need this method?
    return 0;
}

- (CGFloat)_yValueForPresented {
    UIInterfaceOrientation currentOrientation = [(SpringBoard *)[UIApplication sharedApplication] activeInterfaceOrientation];
    CGFloat currentScreenHeight = NUAGetScreenHeightForOrientation(currentOrientation);

    CGFloat totalHeight = _viewController.fullyPresentedHeight;
    CGFloat safeHeight = currentScreenHeight - 100.0;
    return MIN(totalHeight, safeHeight);
}

- (CGFloat)_notificationShadeHeightForLocation:(CGPoint)location initalLocation:(CGPoint)initalLocation {
    // Makes the transition more elegant
    return _isPresenting ? location.y : location.y - initalLocation.y + [self _yValueForPresented];
}

- (CGFloat)project:(CGFloat)initialVelocity decelerationRate:(CGFloat)decelerationRate {
    // From WWDC (UIScrollView.decelerationRate = 0.998)
    return (initialVelocity / 1000.0) * decelerationRate / (1.0 - decelerationRate);
}

#pragma mark - Third stage animation helpers

- (void)_prepareForPresentation {
    [self _beginPresentation];
    self.animating = YES;
}

- (void)_setupViewForPresentation {
    // Create window if necessary
    // _UISpringBoardLockScreenWindowLevel
    if (!_window) {
        _window = [[%c(SBIgnoredForAutorotationSecureWindow) alloc] initWithScreen:[UIScreen mainScreen] debugName:@"NougatWindow" rootViewController:self];
        _window.windowLevel = IS_IOS_OR_NEWER(iOS_11_0) ? 1075 : 1092;
    }

    // Set orientation
    UIInterfaceOrientation orientation = [(SpringBoard *)[UIApplication sharedApplication] activeInterfaceOrientation];
    [_window _setRotatableViewOrientation:orientation updateStatusBar:NO duration:0.0 force:YES];
}

- (void)_beginPresentation {
    // Create view if not already
    [self _setupViewForPresentation];

    // Lock rotation
    [[%c(SBOrientationLockManager) sharedInstance] setLockOverrideEnabled:YES forReason:@"Nougat Visible"];

    SBLockScreenManager *manager = [%c(SBLockScreenManager) sharedInstance];
    if ([manager respondsToSelector:@selector(dashBoardViewController)]) {
        // Only iOS 10+
        SBDashBoardViewController *dashBoardViewController = manager.dashBoardViewController;
        [dashBoardViewController externalBehaviorProviderBehaviorChanged:self];
    } else if ([manager respondsToSelector:@selector(coverSheetViewController)]) {
        CSCoverSheetViewController *coverSheetViewController = manager.coverSheetViewController;
        [coverSheetViewController externalBehaviorProviderBehaviorChanged:self];
    }

    // Do some alpha thingies
    _window.hidden = NO;
    [[%c(SBWindowHidingManager) sharedInstance] setAlpha:1.0 forWindow:_window];

    // Dont do anything if already presenting or animating
    if (self.presented || self.animating) {
        return;
    }

    // Async rendering assertion
    if (!self.asynchronousRenderingAssertion && %c(SBAsynchronousRenderingAssertion)) {
        self.asynchronousRenderingAssertion = [%c(SBAsynchronousRenderingAssertion) initWithReason:NSStringFromClass(self.class)];
    }

    // Stop the Idle timer and banners while presenting
    SBBacklightController *controller = [%c(SBBacklightController) sharedInstance];
    if ([controller respondsToSelector:@selector(setIdleTimerDisabled:forReason:)]) {
        [controller setIdleTimerDisabled:YES forReason:@"Nougat Reveal"];
    } else {
        // iOS 11
        self.idleTimerDisableAssertion = [[%c(SBIdleTimerGlobalCoordinator) sharedInstance] acquireIdleTimerDisableAssertionForReason:@"Nougat Animating"];
    }
    
    // Stop banners when presented
    [[%c(SBBulletinWindowController) sharedInstance] setBusy:YES forReason:@"Nougat Visible"];

    // FBDisplayLayoutElement stuffs
    [self.displayLayoutElement activateWithBuilder:^FBSDisplayLayoutElement *(FBSDisplayLayoutElement *element) {
        // We can cast because we know set the element class
        SBSDisplayLayoutElement *sbsElement = (SBSDisplayLayoutElement *)element;
        sbsElement.fillsDisplayBounds = YES;
        sbsElement.level = _window.windowLevel;
        sbsElement.layoutRole = 4;
        return sbsElement;
    }];

    // Aquire assertion
    if (_newResignActiveAssertion) {
        // iOS 13
        [_newResignActiveAssertion acquire];
    } else {
        // iOS 10-12
        [_oldResignActiveAssertion acquire];
    }

    self.presented = YES;

    // Add child view controller
    _viewController.view.frame = self.view.bounds;
    [self _presentViewToHeight:0.0];

    if (!_viewController.view.superview) {
        [self addChildViewController:_viewController];
        [self.view addSubview:_viewController.view];
        [_viewController didMoveToParentViewController:self];
    }

    [_viewController beginAppearanceTransition:YES animated:NO];
    _viewController.view.hidden = NO;
    [_viewController endAppearanceTransition];
}

- (void)_presentViewToHeight:(CGFloat)height {
    // Apply slowdowns
    CGFloat maxTriggerHeight = [self _yValueForPresented];
    if (height > maxTriggerHeight) {
        height = maxTriggerHeight + (height - maxTriggerHeight) * 0.1;
    }
    // Update the height
    [self _updatePresentedHeight:height];
}

- (void)_updatePresentedHeight:(CGFloat)height {
    // Pass height to VC
    _viewController.presentedHeight = height;
}

- (void)_finishAnimationWithCompletion:(void(^)(void))completion {
    self.animating = NO;

    if (self.presented) {
        BOOL dismissed = self.state == NUANotificationShadeStateDismissed;

        // Make sure at right height
        CGFloat height = dismissed ? [self _yValueForDismissed] : [self _yValueForPresented];
        [self _updatePresentedHeight:height];

        // Resume idle timer and banners
        SBBacklightController *controller = [%c(SBBacklightController) sharedInstance];
        if ([controller respondsToSelector:@selector(setIdleTimerDisabled:forReason:)]) {
            [controller setIdleTimerDisabled:NO forReason:@"Nougat Reveal"];
        } else {
            [self.idleTimerDisableAssertion invalidate];
            self.idleTimerDisableAssertion = nil;
        }

        // Update providers
        SBLockScreenManager *manager = [%c(SBLockScreenManager) sharedInstance];
        if ([manager respondsToSelector:@selector(dashBoardViewController)]) {
            // Only iOS 10+
            SBDashBoardViewController *dashBoardViewController = manager.dashBoardViewController;
            [dashBoardViewController externalBehaviorProviderBehaviorChanged:self];
            [dashBoardViewController externalPresentationProviderPresentationChanged:self];
        } else if ([manager respondsToSelector:@selector(coverSheetViewController)]) {
            CSCoverSheetViewController *coverSheetViewController = manager.coverSheetViewController;
            [coverSheetViewController externalBehaviorProviderBehaviorChanged:self];
            [coverSheetViewController externalPresentationProviderPresentationChanged:self];
        }

        if (dismissed) {
            // Dismissing
            [_viewController beginAppearanceTransition:NO animated:NO];
            _viewController.view.hidden = YES;
            [_viewController endAppearanceTransition];

            self.presented = NO;

            // Async rendering
            if (%c(SBAsynchronousRenderingAssertion)) {
                [self.asynchronousRenderingAssertion invalidate];
                self.asynchronousRenderingAssertion = nil;
            }

            // Unlock rotation
            [[%c(SBOrientationLockManager) sharedInstance] setLockOverrideEnabled:NO forReason:@"Nougat Visible"];

            // Allow for banners
            [[%c(SBBulletinWindowController) sharedInstance] setBusy:NO forReason:@"Nougat Visible"];

            // Deactivate displayLayoutElement
            [self.displayLayoutElement deactivate];

            // Relinquish assertion
            if (_newResignActiveAssertion) {
                // iOS 13
                [_newResignActiveAssertion relinquish];
            } else {
                // iOS 10-12
                [_oldResignActiveAssertion relinquish];
            }

            // Resign key window
            if (@available(iOS 12, *)) {
                [_window resignAsKeyWindow];
            }

            [self _endAnimation];
        } else {
            // Guaranteed presented
            if (IS_IOS_OR_NEWER(iOS_12_0)) {
                // Only on iOS 12+
                [_window makeKeyWindow];
            }
        }
    }

    if (completion) {
        completion();
    }
}

- (void)_endAnimation {
    // Hide the window if dismissing
    if (self.presented || _window.hidden) {
        return;
    }

    _window.hidden = YES;
    self.state = NUANotificationShadeStateDismissed;
}

- (void)_cancelAnimation {
    // Dismiss animated and reset
    [self dismissAnimated:self.visible];
    [self _resetPanGestureStates];
    self.state = NUANotificationShadeStateDismissed;
}

- (void)_resetPanGestureStates {
    _isPresenting = NO;
    _isDismissing = NO;
    _initalTouchLocation = CGPointZero;
}

@end
