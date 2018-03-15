#import "NUANotificationShadeController.h"
#import "NUANotificationCenterInhibitor.h"
#import "NUAPreferenceManager.h"
#import "Macros.h"
#import <FrontBoard/FBDisplayManager.h>
#import <FrontBoard/FBSystemGestureManager.h>
#import <SpringBoard/SBBacklightController.h>
#import <SpringBoard/SBBulletinWindowController.h>
#import <SpringBoard/SBIconController+Private.h>
#import <SpringBoard/SBWindowHidingManager.h>
#import <SpringBoard/SpringBoard+Private.h>

@implementation NUANotificationShadeController

+ (void)notifyNotificationShade:(NSString *)message didActivate:(BOOL)activated {
    if (!message) {
        return;
    }

    //Get if activated or not and send message
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
        // set defaults
        self.presentedState = NUANotificationShadePresentedStateNone;

        // Registering for same notifications that NC does
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(_handleBacklightFadeFinished:) name:@"SBBacklightFadeFinishedNotification" object:nil];
        [center addObserver:self selector:@selector(_handleUIDidLock:) name:@"SBLockScreenUIDidLockNotification" object:nil];
        [center addObserver:self selector:@selector(handleMenuButtonTap) name:@"SBMenuButtonPressedNotification" object:nil];

        //Create and add gesture
        _presentationGestureRecognizer = [[%c(SBScreenEdgePanGestureRecognizer) alloc] initWithTarget:self action:@selector(_handleShowNotificationShadeGesture:)];
        _presentationGestureRecognizer.edges = UIRectEdgeTop;
        [_presentationGestureRecognizer sb_setStylusTouchesAllowed:NO];
        _presentationGestureRecognizer.delegate = self;
        [[%c(FBSystemGestureManager) sharedInstance] addGestureRecognizer:_presentationGestureRecognizer toDisplay:[%c(FBDisplayManager) mainDisplay]];

        // CC calls this in init so we will too
        [self view];
    }

    return self;
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

#pragma mark - Gesture management

- (UIView *)viewForSystemGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    // SBSystemGestureRecognizerDelegate
    return self.view;
}


- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    // Dont do anything if not enabled
    if (![NUAPreferenceManager sharedSettings].enabled) {
        return NO;
    }

    // Use SBHomeScreenWindow to get location
    UIWindow *window = [[%c(SBUIController) sharedInstance] window];
    CGPoint location = [gestureRecognizer locationInView:window];

    // Dont start gesture if in left 1/3 of screen
    return location.x > (kScreenWidth / 3);
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
    [[%c(SBIconController) sharedInstance] setIsEditing:NO withFeedbackBehavior:nil];

    // Disable NC gesture
    NUANotificationCenterInhibitor.inhibited = YES;

    // Begin presentation
    [self _beginAnimationWithGestureRecognizer:gestureRecognizer];
}

- (void)_beginAnimationWithGestureRecognizer:(SBScreenEdgePanGestureRecognizer *)gestureRecognizer {
    // Create view
    [self _setupViewForPresentation];

    // Decide if go to quick or full toggles
    CGPoint location = FBSystemGestureLocationInView(gestureRecognizer, self.view);
    self.presentedState = (location.x > (kScreenWidth / 1.5)) ? NUANotificationShadePresentedStateMainPanel : NUANotificationShadePresentedStateQuickToggles;

    // Begin presentation
    [self beginAnimationWithLocation:location];
}

- (void)_showNotificationShadeGestureChangedWithGestureRecognizer:(SBScreenEdgePanGestureRecognizer *)gestureRecognizer {
    // Present in case not already
    if (!self.visible) {
        [self _beginAnimationWithGestureRecognizer:gestureRecognizer];
    }

    // Defer hard stuffs
    CGPoint location = FBSystemGestureLocationInView(gestureRecognizer, self.view);
    CGPoint velocity = FBSystemGestureVelocityInView(gestureRecognizer, self.view);

    [self updateAnimationWithLocation:location andVelocity:velocity];
}

- (void)_showNotificationShadeGestureEndedWithGestureRecognizer:(SBScreenEdgePanGestureRecognizer *)gestureRecognizer {
    // Some condition with viewForSystemGestureRecognizer and FBSystemGestureLocationInView
    if (!self.visible) {
        [self _beginAnimationWithGestureRecognizer:gestureRecognizer];
    }

    // Uninhibit NC
    NUANotificationCenterInhibitor.inhibited = NO;

    // Defer
    CGPoint velocity = FBSystemGestureVelocityInView(gestureRecognizer, self.view);
    [self endAnimationWithVelocity:velocity wasCancelled:NO];
}

- (void)_showNotificationShadeGestureCancelled {
    [self _showNotificationShadeGestureFailed];
}

- (void)_showNotificationShadeGestureFailed {
    //Cancel transition
    [self _cancelAnimation];
}

#pragma mark - Notification shade delegate

- (void)notificationShadeViewControllerWantsDismissal:(NUANotificationShadeViewController *)controller {
    [self dismissAnimated:YES];
}

- (BOOL)notificationShadeViewControllerShouldShowQuickToggles:(NUANotificationShadeViewController *)controller {
    // Let the VC know to show quick toggles
    return self.presentedState == NUANotificationShadePresentedStateQuickToggles;
}

- (void)notificationShadeViewController:(NUANotificationShadeViewController *)controller handlePan:(UIPanGestureRecognizer *)panGesture {
    // Defer to use presentation methods (Note handles expanding further and dismissing)
    switch (panGesture.state) {
        case UIGestureRecognizerStatePossible:
            break;
        case UIGestureRecognizerStateBegan: {
            CGPoint location = [panGesture locationInView:self.view];
            [self beginAnimationWithLocation:location];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint location = [panGesture locationInView:self.view];
            CGPoint velocity = [panGesture velocityInView:self.view];
            [self updateAnimationWithLocation:location andVelocity:velocity];
            break;
        }
        case UIGestureRecognizerStateEnded: {
            CGPoint velocity = [panGesture velocityInView:self.view];
            [self endAnimationWithVelocity:velocity wasCancelled:NO];
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

- (BOOL)notificationShadeViewController:(NUANotificationShadeViewController *)controller canHandleGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    return (_presentationGestureRecognizer.state == UIGestureRecognizerStateBegan) ? NO : (_presentationGestureRecognizer.state != UIGestureRecognizerStateChanged);
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

- (void)handleMenuButtonTap {
    if (!self.visible) {
        return;
    }

    // Dismiss drawer for home button tap
    [self dismissAnimated:YES];
}

#pragma mark - Presentation

- (void)dismissAnimated:(BOOL)animated {
    [self dismissAnimated:animated completely:YES];
}

- (void)dismissAnimated:(BOOL)animated completely:(BOOL)completely {
    // Animate
    if (!self.presented) {
        return;
    }

    // Uninhibit NC if was
    NUANotificationCenterInhibitor.inhibited = NO;
    self.presentedState = completely ? NUANotificationShadePresentedStateNone : NUANotificationShadePresentedStateQuickToggles;

    self.animating = YES;

    CGFloat duration  = animated ? 0.4 : 0.0;
    [UIView animateWithDuration:duration animations:^{
        CGFloat height = [self _yValueForDismissed];
        [self _presentViewToHeight:height];
    } completion:^(BOOL finished) {
        [self _finishAnimation:NO completion:nil];
    }];
    }

- (void)presentAnimated:(BOOL)animated {
    [self presentAnimated:animated showQuickSettings:YES];
}

- (void)presentAnimated:(BOOL)animated showQuickSettings:(BOOL)showSettings {
    // Do setup
    [self _beginPresentation];
    self.presentedState = showSettings ? NUANotificationShadePresentedStateQuickToggles : NUANotificationShadePresentedStateMainPanel;

    self.animating = YES;

    CGFloat duration = animated ? 0.4 : 0.0;
    [UIView animateWithDuration:duration animations:^{
        CGFloat height = [self _yValueForPresented];
        [self _presentViewToHeight:height];
    } completion:^(BOOL finished) {
        [self _finishAnimation:YES completion:nil];
    }];
}

#pragma mark - Animation helpers

- (void)beginAnimationWithLocation:(CGPoint)location {
    // Set if is presenting or dismissing
    _isPresenting = !self.presented;
    _isDismissing = self.presented;

    // Setup view controller
    [self _beginPresentation];

    // Slide to height of touch location
    if (_isPresenting) {
        [UIView animateWithDuration:0.2 animations:^{
            // Touch location is the height
            CGFloat height = location.y;
            [self _presentViewToHeight:height];
        }];
    }
}

- (void)updateAnimationWithLocation:(CGPoint)location andVelocity:(CGPoint)velocity {
    // Make sure visible before continue
    if (!self.presented || !self.visible) {
        return;
    }

    if (_isDismissing) {
        // Do some stuff
    }

    CGFloat height = location.y;
    [self _presentViewToHeight:height];
}

- (void)endAnimationWithVelocity:(CGPoint)velocity wasCancelled:(BOOL)cancelled {
    if (!self.presented || !self.visible || _isDismissing) {
        return;
    }


    // End presentation
    //[self _endPresentation];

    // Reset ivars
    [self _resetPanGestureStates];
}

- (BOOL)isVisible {
    return !_window.hidden;;
}

- (CGFloat)_yValueForPresented {
    // Use current state to calculate yval
    CGFloat quickHeight = kScreenHeight / 5;
    CGFloat fullHeight = kScreenHeight / 1.5;
    return (self.presentedState == NUANotificationShadePresentedStateQuickToggles) ? quickHeight : fullHeight;
}

- (CGFloat)_yValueForDismissed {
    // Do we really need this method?
    return 0;
}

- (void)_setupViewForPresentation {
    // Create window if necessary
    if (!_window) {
        _window = [[%c(SBIgnoredForAutorotationSecureWindow) alloc] initWithScreen:[UIScreen mainScreen] debugName:@"NougatWindow" rootViewController:self];
        _window.windowLevel = 1092;
    }

    // Set orientation
    UIInterfaceOrientation orientation = [(SpringBoard *)[UIApplication sharedApplication] activeInterfaceOrientation];
    [_window _setRotatableViewOrientation:orientation updateStatusBar:NO duration:0.0 force:YES];
}

- (void)_beginPresentation {
    // Create view if not already
    [self _setupViewForPresentation];

    // Do some alpha thingies
    _window.hidden = NO;
    [[%c(SBWindowHidingManager) sharedInstance] setAlpha:1.0 forWindow:_window];

    // Dont do anything if already presenting or animating
    if (self.presented || self.animating) {
        return;
    }

    [[%c(SBBacklightController) sharedInstance] setIdleTimerDisabled:YES forReason:@"Nougat Reveal"];
    [[%c(SBBulletinWindowController) sharedInstance] setBusy:YES forReason:@"Nougat Reveal"];

    self.presented = YES;

    // Add child view controller
    _viewController.view.frame = self.view.bounds;
    [self _presentViewToHeight:0.0];

    if (!_viewController.view.superview) {
        [self addChildViewController:_viewController];
        [self.view addSubview:_viewController.view];
        [_viewController didMoveToParentViewController:self];
    }

    _viewController.view.hidden = NO;
}

- (void)_presentViewToHeight:(CGFloat)height {
    // Calculate percentage
    //CGFloat closedYValue = [self _yValueForDismissed];
    CGFloat openYValue = [self _yValueForPresented];
    CGFloat percentage = height / openYValue;
    [self _updateToRevealPercentage:percentage];
}

- (void)_updateToRevealPercentage:(CGFloat)percentage {
    _viewController.revealPercentage = percentage;
}

- (void)_finishAnimation:(BOOL)presented {
    self.animating = NO;

    if (!self.presented) {
        return;
    }

    CGFloat percentage = presented ? 1.0 : 0.0
    [self _updateToRevealPercentage:percentage];

    [[%c(SBBacklightController) sharedInstance] setIdleTimerDisabled:NO forReason:@"Nougat Reveal"];
    [[%c(SBBulletinWindowController) sharedInstance] setBusy:NO forReason:@"Nougat Reveal"];

    if (!presented) {
        // Dismissing
        self.view.hidden = YES;
        self.presented = NO;
        [self _endAnimation];
    }
}

- (void)_endAnimation {
    // Hide the window if dismissing
    if (self.presented || _window.hidden) {
        return;
    }

    _window.hidden = YES;
}

- (void)_cancelAnimation {
    // Uninhibit NC
    NUANotificationCenterInhibitor.inhibited = NO;

    // Dismiss animated and reset
    [self dismissAnimated:self.visible];
    [self _resetPanGestureStates];
}

- (void)_resetPanGestureStates {
    _isPresenting = NO;
    _isDismissing = NO;
}

@end
