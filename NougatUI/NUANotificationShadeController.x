#import "NUANotificationShadeController.h"
#import <Macros.h>
#import <NougatServices/NougatServices.h>
#import <FrontBoard/FBDisplayManager.h>
#import <FrontBoard/FBSystemGestureManager.h>
#import <SpringBoard/SBBacklightController.h>
#import <SpringBoard/SBBulletinWindowController.h>
#import <SpringBoard/SBControlCenterController+Private.h>
#import <SpringBoard/SBDashBoardRegion.h>
#import <SpringBoard/SBDashBoardViewController.h>
#import <SpringBoard/SBIconController+Private.h>
#import <SpringBoard/SBIdleTimerGlobalCoordinator.h>
#import <SpringBoard/SBLockScreenManager+Private.h>
#import <SpringBoard/SBNotificationCenterController+Private.h>
#import <SpringBoard/SBOrientationLockManager+Private.h>
#import <SpringBoard/SBWindowHidingManager.h>
#import <SpringBoard/SpringBoard+Private.h>
#import <SpringBoardServices/SBSDisplayLayoutElement.h>
#import <UIKit/UIApplication+Private.h>
#import <UIKit/UIScreen+Internal.h>
#import <UIKit/UIStatusBar.h>
#import <UIKit/UIStatusBar_Modern.h>
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
        self.presentedState = NUANotificationShadePresentedStateNone;

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
        }

        self.displayLayoutElement = [[FBDisplayLayoutElement alloc] initWithDisplayType:FBSDisplayTypeMain identifier:@"NUANotificationShade" elementClass:%c(SBSDisplayLayoutElement)];

        //Create and add gesture
        _presentationGestureRecognizer = [[%c(SBScreenEdgePanGestureRecognizer) alloc] initWithTarget:self action:@selector(_handleShowNotificationShadeGesture:) type:UIScreenEdgePanRecognizerTypeOther];
        _presentationGestureRecognizer.edges = UIRectEdgeTop;
        [_presentationGestureRecognizer sb_setStylusTouchesAllowed:NO];
        _presentationGestureRecognizer.delegate = self;
        [[FBSystemGestureManager sharedInstance] addGestureRecognizer:_presentationGestureRecognizer toDisplay:[%c(FBDisplayManager) mainDisplay]];

        // Add assertion
        _resignActiveAssertion = [[FBUIApplicationSceneDeactivationAssertion alloc] initWithReason:UIApplicationSceneDeactivationReasonControlCenter];

        // CC calls this in init so we will too
        [self view];
    }

    return self;
}

- (void)dealloc {
    SBLockScreenManager *manager = [%c(SBLockScreenManager) sharedInstance];
    if ([manager respondsToSelector:@selector(dashBoardViewController)]) {
        // Only iOS 10+
        SBDashBoardViewController *dashBoardViewController = manager.dashBoardViewController;
        [dashBoardViewController unregisterExternalBehaviorProvider:self];
        [dashBoardViewController unregisterExternalPresentationProvider:self];
    }

    // Relinquish assertion
    [_resignActiveAssertion relinquish];
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

#pragma mark - Gesture management

- (UIView *)viewForSystemGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    // SBSystemGestureRecognizerDelegate
    return self.view;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    // Dont do anything if not enabled
    return [NUAPreferenceManager sharedSettings].enabled && ![[%c(SBNotificationCenterController) sharedInstance] isVisible] && ![[%c(SBControlCenterController) sharedInstance] isVisible];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // Get location of touch
    CGPoint location = [self _locationOfTouchInActiveInterfaceOrientation:touch gestureRecognizer:gestureRecognizer];

    // Only start if within the notch and CC isnt present
    return [self _isLocationXWithinNotchRegion:location];
}

- (CGPoint)_locationOfTouchInActiveInterfaceOrientation:(UITouch *)touch gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint location = [touch locationInView:nil];

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

- (BOOL)_isLocationXWithinNotchRegion:(CGPoint)location {
    UIStatusBar *statusBar = [UIApplication sharedApplication].statusBar;
    if (statusBar && [statusBar isKindOfClass:%c(UIStatusBar_Modern)]) {
        // Use notch insets
        UIStatusBar_Modern *modernStatusBar = (UIStatusBar_Modern *)statusBar;
        CGRect leadingFrame = [modernStatusBar frameForPartWithIdentifier:@"fittingLeadingPartIdentifier"];
        CGRect trailingFrame = [modernStatusBar frameForPartWithIdentifier:@"fittingTrailingPartIdentifier"];

        CGFloat maxLeadingX = CGRectGetMaxX(leadingFrame);
        if (maxLeadingX > 5000.0) {
            // Screen recording and carplay both cause the leading frame to be infinite, fallback to 1/4
            maxLeadingX = kScreenWidth / 4;
        }

        // Get min trailing x taking into account orientation
        CGFloat minTrailingX = kScreenWidth - (CGRectGetMaxX(trailingFrame) - CGRectGetMinX(trailingFrame));
        return location.x > maxLeadingX && location.x < minTrailingX;
    } else {
        // Regular old frames
        return location.x > (kScreenWidth / 3) && location.x < (kScreenWidth * 2 / 3);
    }
}

- (void)_handleShowNotificationShadeGesture:(SBScreenEdgePanGestureRecognizer *)recognizer {
    // Stealing stuff from SB's implementation of CC and NC and mashing them into a CCNC
    switch (recognizer.state) {
        case UIGestureRecognizerStatePossible:
            break;
        case UIGestureRecognizerStateBegan:
            [self _showNotificationShadeGestureBeganWithGestureRecognizer:recognizer];
            break;
        case UIGestureRecognizerStateChanged:
            [self _showNotificationShadeGestureChangedWithGestureRecognizer:recognizer];
            break;
        case UIGestureRecognizerStateEnded:
            [self _showNotificationShadeGestureEndedWithGestureRecognizer:recognizer];
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
    [[%c(SBIconController) sharedInstance] setIsEditing:NO];

    // Begin presentation
    [self _beginAnimationWithGestureRecognizer:gestureRecognizer];
}

- (void)_beginAnimationWithGestureRecognizer:(SBScreenEdgePanGestureRecognizer *)gestureRecognizer {
    // Create view
    [self _setupViewForPresentation];

    // Begin presentation
    CGPoint location = FBSystemGestureLocationInView(gestureRecognizer, self.view);
    [self beginAnimationWithLocation:location];
}

- (void)_showNotificationShadeGestureChangedWithGestureRecognizer:(SBScreenEdgePanGestureRecognizer *)gestureRecognizer {
    // Present in case not already
    if (!self.visible) {
        [self _beginAnimationWithGestureRecognizer:gestureRecognizer];
    }

    // Defer hard stuffs
    CGPoint location = FBSystemGestureLocationInView(gestureRecognizer, self.view);
    [self updateAnimationWithLocation:location];
}

- (void)_showNotificationShadeGestureEndedWithGestureRecognizer:(SBScreenEdgePanGestureRecognizer *)gestureRecognizer {
    // Defer
    CGPoint velocity = FBSystemGestureVelocityInView(gestureRecognizer, self.view);
    CGPoint location = FBSystemGestureLocationInView(gestureRecognizer, self.view);
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

#pragma mark - Notification shade delegate

- (void)notificationShadeViewControllerWantsExpansion:(NUANotificationShadeViewController *)controller {
    // Since expanding, show main panel
    [self presentAnimated:YES showQuickSettings:NO];
}

- (void)notificationShadeViewControllerWantsDismissal:(NUANotificationShadeViewController *)controller completely:(BOOL)completely {
    [self dismissAnimated:YES completely:completely];
}

- (void)notificationShadeViewController:(NUANotificationShadeViewController *)controller handlePan:(UIPanGestureRecognizer *)panGestureRecognizer {
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

- (void)notificationShadeViewController:(NUANotificationShadeViewController *)controller handleTap:(UITapGestureRecognizer *)tapGestureRecognizer {
    [self dismissAnimated:YES];
}

- (BOOL)notificationShadeViewController:(NUANotificationShadeViewController *)controller canHandleGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    return ((_presentationGestureRecognizer.state == UIGestureRecognizerStateBegan) ? NO : (_presentationGestureRecognizer.state != UIGestureRecognizerStateChanged)) && !self.animating;
}

- (CGFloat)notificationShadeViewControllerWantsFullyPresentedHeight:(NUANotificationShadeViewController *)controller {
    return [self _yValueForFullyPresented];
}

#pragma mark - Dashboard participating

- (NSString *)dashBoardIdentifier {
    return NSStringFromClass(self.class);
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
    if (self.presented && %c(SBDashBoardRegion)) {
        SBDashBoardRegion *region = [%c(SBDashBoardRegion) regionForCoordinateSpace:self.view];
        region = [region role:SBDashBoardRegionRoleOverlay];
        return @[region];
    }

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
    // Default to dismiss completely
    [self dismissAnimated:animated completely:YES];
}

- (void)dismissAnimated:(BOOL)animated completely:(BOOL)completely {
    // Always going to dismiss completely
    if (!self.presented) {
        return;
    }

    self.animating = YES;
    self.presentedState = completely ? NUANotificationShadePresentedStateNone : NUANotificationShadePresentedStateQuickToggles;

    // Animate out
    CGFloat height = [self _yValueForCurrentState];
    if (animated) {
        CGFloat baseHeight = _viewController.presentedHeight;
        [self _updatePresentedHeightGradually:height baseHeight:baseHeight completion:^{
            [self _finishAnimationWithCompletion:nil];
        }];
    } else {
        [self _updatePresentedHeight:height];
        [self _finishAnimationWithCompletion:nil];
    }
}

- (void)presentAnimated:(BOOL)animated {
    [self presentAnimated:animated showQuickSettings:YES];
}

- (void)presentAnimated:(BOOL)animated showQuickSettings:(BOOL)showSettings {
    // Dont start if at main panel
    if (self.presentedState == NUANotificationShadePresentedStateMainPanel) {
        return;
    }

    [self _beginPresentation];

    self.animating = YES;
    self.presentedState = showSettings ? NUANotificationShadePresentedStateQuickToggles : NUANotificationShadePresentedStateMainPanel;

    // Animate in
    CGFloat height = [self _yValueForCurrentState];
    if (animated) {
        CGFloat baseHeight = _viewController.presentedHeight;
        [self _updatePresentedHeightGradually:height baseHeight:baseHeight completion:^{
            [self _finishAnimationWithCompletion:nil];
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
            self.presentedState = (projectedY >= targetY) ? NUANotificationShadePresentedStateQuickToggles : NUANotificationShadePresentedStateNone; 
        } else {
            if (self.presentedState == NUANotificationShadePresentedStateQuickToggles) {
                // Decide if dismiss or fully present
                UIInterfaceOrientation orientation = [(SpringBoard *)[UIApplication sharedApplication] activeInterfaceOrientation];
                BOOL overrideForLandscape = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) && UIInterfaceOrientationIsLandscape(orientation);

                CGFloat targetMainY = [self _yValueForFullyPresented] * 0.7;
                CGFloat targetCloseY = [self _yValueForPresented] * 1.4;
                if ((projectedY >= targetMainY) && !overrideForLandscape) {
                    self.presentedState = NUANotificationShadePresentedStateMainPanel;
                } else if (projectedY <= targetCloseY) {
                    self.presentedState = NUANotificationShadePresentedStateNone;
                }
            } else if (self.presentedState == NUANotificationShadePresentedStateMainPanel) {
                // Decide if collapse
                CGFloat targetCollapseY = [self _yValueForFullyPresented] * 0.45;
                self.presentedState = (projectedY <= targetCollapseY) ? NUANotificationShadePresentedStateQuickToggles : NUANotificationShadePresentedStateMainPanel;
            }
        }

        // Animate to finished height
        CGFloat height = [self _yValueForCurrentState];
        [self _updatePresentedHeightGradually:height baseHeight:_viewController.presentedHeight completion:^{
            [self _finishAnimationWithCompletion:completion];
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
    // Height of the quick toggles view
    return 150.0;
}

- (CGFloat)_yValueForFullyPresented {
    // Height of the main panel, depends on amount of toggles
    NSUInteger togglesCount = [NUAPreferenceManager sharedSettings].enabledToggles.count;
    if (togglesCount > 6) {
        return 500.0;
    } else if (togglesCount > 3) {
        return 400.0;
    } else {
        return 300.0;
    }
}

- (CGFloat)_yValueForCurrentState {
    switch (self.presentedState) {
        case NUANotificationShadePresentedStateNone:
            return [self _yValueForDismissed];
        case NUANotificationShadePresentedStateQuickToggles:
            return [self _yValueForPresented];
        case NUANotificationShadePresentedStateMainPanel: 
            return [self _yValueForFullyPresented];
    }
}

- (CGFloat)_notificationShadeHeightForLocation:(CGPoint)location initalLocation:(CGPoint)initalLocation {
    // Makes the transition more elegant
    return _isPresenting ? location.y : location.y - initalLocation.y + [self _yValueForCurrentState];
}

- (CGFloat)project:(CGFloat)initialVelocity decelerationRate:(CGFloat)decelerationRate {
    // From WWDC (UIScrollView.decelerationRate = 0.998)
    return (initialVelocity / 1000.0) * decelerationRate / (1.0 - decelerationRate);
}

#pragma mark - Third stage animation helpers

- (void)_prepareForPresentation {
    if (_animationTimer) {
        [_animationTimer invalidate];
        _animationTimer = nil;
    }

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
    }

    // Do some alpha thingies
    _window.hidden = NO;
    [[%c(SBWindowHidingManager) sharedInstance] setAlpha:1.0 forWindow:_window];

    // Dont do anything if already presenting or animating
    if (self.presented || self.animating) {
        return;
    }

    // Stop the Idle timer and banners while presenting
    SBBacklightController *controller = [%c(SBBacklightController) sharedInstance];
    if ([controller respondsToSelector:@selector(setIdleTimerDisabled:forReason:)]) {
        [controller setIdleTimerDisabled:YES forReason:@"Nougat Reveal"];
    } else {
        // iOS 11
        self.idleTimerDisableAssertion = [[%c(SBIdleTimerGlobalCoordinator) sharedInstance] acquireIdleTimerDisableAssertionForReason:@"Nougat Animating"];
    }
    
    [[%c(SBBulletinWindowController) sharedInstance] setBusy:YES forReason:@"Nougat Reveal"];

    // FBDisplayLayoutElement stuffs
    [self.displayLayoutElement activateWithBuilder:^FBSDisplayLayoutElement *(FBSDisplayLayoutElement *element) {
        // We can cast because we know set the element class
        SBSDisplayLayoutElement *sbsElement = (SBSDisplayLayoutElement *)element;
        sbsElement.fillsDisplayBounds = YES;
        sbsElement.level = _window.windowLevel;
        sbsElement.layoutRole = SBSDisplayLayoutRoleOverlay;
        return sbsElement;
    }];

    // Aquire assertion
    [_resignActiveAssertion acquire];

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
    // Find when to trigger slowdowns
    CGFloat maxTriggerHeight = 0;
    CGFloat minTriggerHeight = 0;
    switch (self.presentedState) {
        case NUANotificationShadePresentedStateNone: {
            // Max Height: Quick toggles
            maxTriggerHeight = [self _yValueForPresented];
            break;
        }
        case NUANotificationShadePresentedStateQuickToggles: {
            // Max Height: Main Panel
            maxTriggerHeight = [self _yValueForFullyPresented];
            break;
        }
        case NUANotificationShadePresentedStateMainPanel: {
            // Max Height: self
            // Min Height: Quick toggles
            maxTriggerHeight = [self _yValueForFullyPresented];
            minTriggerHeight = [self _yValueForPresented];
            break;
        }
    }

    // Overrides for if in landscape on iphones
    UIInterfaceOrientation orientation = [(SpringBoard *)[UIApplication sharedApplication] activeInterfaceOrientation];
    if (([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) && UIInterfaceOrientationIsLandscape(orientation)) {
        maxTriggerHeight = [self _yValueForPresented];
    }

    // Apply slowdowns
    if (height > maxTriggerHeight) {
        height = maxTriggerHeight + (height - maxTriggerHeight) * 0.1;
    } else if (height < minTriggerHeight) {
        height = minTriggerHeight - (minTriggerHeight - height) * 0.1;
    }

    // Update the height
    [self _updatePresentedHeight:height];
}

- (void)_updatePresentedHeight:(CGFloat)height {
    // Pass height to VC
    _viewController.presentedHeight = height;
}

CGFloat multiplerAdjustedForEasing(CGFloat t) {
    // Use material design spec bezier curve to get multiplier
    CGFloat xForT = (0.6 * (1 - t) * t * t) + (1.2 * (1 - t) * (1 - t) * t) + ((1 - t) * (1 - t) * (1 - t));
    CGFloat yForX = (3 * xForT * xForT * (1 - xForT)) + (xForT * xForT * xForT);
    return 1 - yForX;
}

- (void)_updatePresentedHeightGradually:(CGFloat)targetHeight baseHeight:(CGFloat)baseHeight completion:(void(^)(void))completion {
    __block NSInteger fireTimes = 0;
    __block CGFloat difference = targetHeight - baseHeight;

    __weak __typeof(self) weakSelf = self;
    _animationTimer = [NUADisplayLink displayLinkWithBlock:^(CADisplayLink *displayLink) {
        if (fireTimes == 20) {
            [displayLink invalidate];
            [weakSelf _updatePresentedHeight:targetHeight];

            if (completion) {
                completion();
            }
            return;
        }

        
        fireTimes++;
        CGFloat t = fireTimes / 21.0;
        CGFloat multiplier = multiplerAdjustedForEasing(t);

        // Update height
        CGFloat newHeight = baseHeight + (difference * multiplier);
        [weakSelf _updatePresentedHeight:newHeight];
    }];
}

- (void)_finishAnimationWithCompletion:(void(^)(void))completion {
    self.animating = NO;

    if (self.presented) {
        BOOL dismissed = self.presentedState == NUANotificationShadePresentedStateNone;

        // Make sure at right height
        CGFloat height = [self _yValueForCurrentState];
        [self _updatePresentedHeight:height];

        // Resume idle timer and banners
        SBBacklightController *controller = [%c(SBBacklightController) sharedInstance];
        if ([controller respondsToSelector:@selector(setIdleTimerDisabled:forReason:)]) {
            [controller setIdleTimerDisabled:NO forReason:@"Nougat Reveal"];
        } else {
            [self.idleTimerDisableAssertion invalidate];
            self.idleTimerDisableAssertion = nil;
        }

        [[%c(SBBulletinWindowController) sharedInstance] setBusy:NO forReason:@"Nougat Reveal"];

        if (dismissed) {
            // Dismissing
            [_viewController beginAppearanceTransition:NO animated:NO];
            _viewController.view.hidden = YES;
            [_viewController endAppearanceTransition];

            self.presented = NO;

            // Unlock rotation
            [[%c(SBOrientationLockManager) sharedInstance] setLockOverrideEnabled:NO forReason:@"Nougat Visible"];

            // Deactivate displayLayoutElement
            [self.displayLayoutElement deactivate];

            // Relinquish assertion
            [_resignActiveAssertion relinquish];

            [self _endAnimation];

            SBLockScreenManager *manager = [%c(SBLockScreenManager) sharedInstance];
            if ([manager respondsToSelector:@selector(dashBoardViewController)]) {
                // Only iOS 10+
                SBDashBoardViewController *dashBoardViewController = manager.dashBoardViewController;
                [dashBoardViewController externalBehaviorProviderBehaviorChanged:self];
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
    self.presentedState = NUANotificationShadePresentedStateNone;
}

- (void)_cancelAnimation {
    // Dismiss animated and reset
    [self dismissAnimated:self.visible];
    [self _resetPanGestureStates];
    self.presentedState = NUANotificationShadePresentedStateNone;
}

- (void)_resetPanGestureStates {
    _isPresenting = NO;
    _isDismissing = NO;
    _initalTouchLocation = CGPointZero;
}

@end
