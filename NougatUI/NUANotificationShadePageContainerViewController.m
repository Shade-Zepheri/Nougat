#import "NUANotificationShadePageContainerViewController.h"
#import "NUAPropertyAnimator.h"
#import <SpringBoard/SpringBoard+Private.h>
#import <UIKit/UIKit+Private.h>
#import <Macros.h>

@interface NUANotificationShadePageContainerViewController ()
@property (getter=isDismissing, assign, nonatomic) BOOL dismissing;
@property (strong, nonatomic) NUAPropertyAnimator *propertyAnimator;

@end

@implementation NUANotificationShadePageContainerViewController

#pragma mark - Initialization

- (instancetype)initWithContentViewController:(UIViewController<NUANotificationShadePageContentProvider> *)viewController andDelegate:(id<NUANotificationShadePageContainerViewControllerDelegate>)delegate {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Set defaults
        self.dismissing = NO;

        _contentViewController = viewController;
        _contentViewController.delegate = self;

        self.delegate = delegate;
    }

    return self;
}

- (void)dealloc {
    // Stop animating
    [self _stopAnimating];
}

#pragma mark - View management

- (void)loadView {
    NUANotificationShadePanelView *panelView = [[NUANotificationShadePanelView alloc] initWithPreferences:self.notificationShadePreferences];
    self.view = panelView;
}

- (void)viewDidLoad {
    [self addChildViewController:self.contentViewController];
    [self _panelView].contentView = self.contentViewController.view;
    [self.contentViewController didMoveToParentViewController:self];

    [self _panelView].fullyPresentedHeight = self.contentViewController.fullyPresentedHeight;

    // Add pan gesture
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_handlePanGesture:)];
    self.panGesture.maximumNumberOfTouches = 1;

    // Increase pan gesture tolerance and not fail past max touches
    self.panGesture.failsPastMaxTouches = NO;
    self.panGesture._hysteresis = 20.0;

    [self.view addGestureRecognizer:self.panGesture];
    self.panGesture.delegate = self;

    [super viewDidLoad];
}

- (NUANotificationShadePanelView *)_panelView {
    return (NUANotificationShadePanelView *)self.view;
}

- (BOOL)_canShowWhileLocked {
    // New on iOS 13
    return YES;
}

#pragma mark - Properties

- (CGFloat)revealPercentage {
    return self.contentViewController.revealPercentage;
}

- (void)setRevealPercentage:(CGFloat)revealPercentage {
    // Pass to views
    self.contentViewController.revealPercentage = revealPercentage;
    [self _panelView].revealPercentage = revealPercentage;

    // Pass to delegate
    [self.delegate containerViewController:self updatedRevealPercentage:revealPercentage];
}

- (void)setPresentedHeight:(CGFloat)height {
    _presentedHeight = height;

    // Pass on to views
    [self _panelView].inset = height;
}

- (CGFloat)contentPresentedHeight {
    return self.contentViewController.fullyPresentedHeight;
}

#pragma mark - Delegate

- (void)contentViewControllerWantsDismissal:(UIViewController *)contentViewController completely:(BOOL)completely {
    __weak __typeof(self) weakSelf = self;
    CGFloat baseHeight = CGRectGetHeight(self.view.bounds);
    [self _updateExpandedHeight:150.0 baseHeight:baseHeight completion:^{
        if (!completely) {
            return;
        }

        // Dismiss entirely
        [weakSelf.delegate containerViewControllerWantsDismissal:self];
    }];
}

- (void)contentViewControllerWantsExpansion:(UIViewController *)contentViewController {
    CGFloat baseHeight = CGRectGetHeight(self.view.bounds);
    CGFloat fullHeight = self.contentViewController.fullyPresentedHeight;
    [self _updateExpandedHeight:fullHeight baseHeight:baseHeight completion:nil];
}

- (void)handleDismiss:(BOOL)animated completion:(void(^)(void))completion {
    // Cancel existing animations
    [self _stopAnimating];

    // Allow dispatching of delegate methods
    if (animated) {
        CGFloat baseHeight = CGRectGetHeight(self.view.bounds);
        [self _updateExpandedHeight:150.0 baseHeight:baseHeight completion:completion];
    } else {
        [self _updateExpandedHeight:150.0];

        if (completion) {
            completion();
        }
    }
}

- (NUAPreferenceManager *)notificationShadePreferences {
    return [self.delegate notificationShadePreferences];
}

#pragma mark - Gestures

- (void)_handlePanGesture:(UIPanGestureRecognizer *)recognizer {
    // Only used for expansion or collapsing
    if (!recognizer.view) {
        return;
    }

    NUANotificationShadePanelView *panel = [self _panelView];
    CGPoint translation = [recognizer translationInView:panel.superview];

    switch (recognizer.state) {
        case UIGestureRecognizerStatePossible:
            break;
        case UIGestureRecognizerStateBegan:
            // Capture initial height
            _initialHeight = CGRectGetHeight(panel.bounds);
            break;
        case UIGestureRecognizerStateChanged: {
            // Expand the height
            [self _expandHeightWithTranslation:translation];
            break;
        }
        case UIGestureRecognizerStateEnded: {
            // Set final height
            CGPoint velocity = [recognizer velocityInView:panel.superview];
            [self _endExpansionWithTranslation:translation velocity:velocity];
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            // Reset height
            [self _updateExpandedHeight:_initialHeight];
            break;
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    // Prevent on iPhones when in landscape
    BOOL isIPad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
    UIInterfaceOrientation orientation = [(SpringBoard *)[UIApplication sharedApplication] activeInterfaceOrientation];
    BOOL isInLandscape = UIInterfaceOrientationIsLandscape(orientation);
    return !(!isIPad && isInLandscape);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // Only allow touch inside of panel
    CGPoint location = [touch locationInView:self.view];
    return CGRectContainsPoint(self.view.frame, location);
}

#pragma mark - Property Animator

- (void)_startAnimatingWithDuration:(NSTimeInterval)duration initialValue:(CGFloat)initialValue finalValue:(CGFloat)finalValue expanding:(BOOL)expanding completion:(void(^)(void))completion {
    // Create animator
    __weak __typeof(self) weakSelf = self;
    self.propertyAnimator = [[NUAPropertyAnimator alloc] initWithDuration:duration initialValue:initialValue finishedValue:finalValue animations:^(CGFloat newValue) {
        if (expanding) {
            [weakSelf _updateExpandedHeight:newValue];
        } else {
            [weakSelf _updatePresentedHeight:newValue];
        }
    }];

    if (completion) {
        // Add completion
        [self.propertyAnimator addCompletion:^(BOOL finished) {
            if (!finished) {
                return;
            }

            completion();
        }];
    }

    // Start animator
    [self.propertyAnimator startAnimation];
}

- (void)_stopAnimating {
    if (!self.propertyAnimator) {
        // Doesnt exist
        return;
    }

    [self.propertyAnimator stopAnimation:YES];
    self.propertyAnimator = nil;
}

#pragma mark - Helpers

- (void)_updateExpandedHeight:(CGFloat)targetHeight baseHeight:(CGFloat)baseHeight completion:(void(^)(void))completion {
    if (baseHeight == targetHeight) {
        // Already at target, no need to do anything
        if (completion) {
            completion();
        }

        return;
    }

    // Pass through
    [self _startAnimatingWithDuration:0.4 initialValue:baseHeight finalValue:targetHeight expanding:YES completion:completion];
}

- (void)_updatePresentedHeight:(CGFloat)targetHeight baseHeight:(CGFloat)baseHeight completion:(void(^)(void))completion {
    if (baseHeight == targetHeight) {
        // Already at target, no need to do anything
        if (completion) {
            completion();
        }

        return;
    }

    // Pass through
    [self _startAnimatingWithDuration:0.4 initialValue:baseHeight finalValue:targetHeight expanding:NO completion:completion];
}

#pragma mark - Presentation

- (void)updateToFinalPresentedHeight:(CGFloat)finalHeight completion:(void(^)(void))completion {
    // Allow delegates to adjust
    self.dismissing = YES;

    __weak __typeof(self) weakSelf = self;
    [self _updatePresentedHeight:finalHeight baseHeight:self.presentedHeight completion:^{
        // Add call to disable dispatching delegate methods
        weakSelf.dismissing = NO;

        if (!completion) {
            return;
        }

        completion();
    }];
}

- (void)_updatePresentedHeight:(CGFloat)height {
    self.presentedHeight = height;

    if (!self.dismissing) {
        // Dont dispatch delegate unless dismissing by tap
        return;
    }

    [self.delegate containerViewController:self updatedPresentedHeight:height];
}

#pragma mark - Expansion

- (void)_expandHeightWithTranslation:(CGPoint)translation {
    CGFloat newHeight = _initialHeight + translation.y;
    CGFloat fullHeight = self.contentViewController.fullyPresentedHeight;
    if (newHeight > fullHeight) {
        // Apply slowdown
        newHeight = fullHeight + (newHeight - fullHeight) * 0.1;
    } else if (newHeight < 150.0) {
        newHeight = 150.0 - (150.0 - newHeight) * 0.1;
    }

    [self _updateExpandedHeight:newHeight];
}

- (void)_endExpansionWithTranslation:(CGPoint)translation velocity:(CGPoint)velocity {
    CGFloat newHeight = _initialHeight + translation.y;
    CGFloat projectedHeight = newHeight + [self project:velocity.y decelerationRate:0.998];

    CGFloat fullHeight = self.contentViewController.fullyPresentedHeight;
    CGFloat expandTargetHeight = fullHeight * 0.7;
    CGFloat collapseTargetHeight = 150.0 * 1.4;

    CGFloat targetHeight = _initialHeight;
    if (projectedHeight >= expandTargetHeight) {
        // Expand
        targetHeight = fullHeight;

        // Set state
        _panelState = NUANotificationShadePanelStateExpanded;
    } else if (projectedHeight <= collapseTargetHeight) {
        // Collapse
        targetHeight = 150.0;

        // Set state
        _panelState = NUANotificationShadePanelStateCollapsed;
    }

    CGFloat baseHeight = CGRectGetHeight(self.view.bounds);
    [self _updateExpandedHeight:targetHeight baseHeight:baseHeight completion:nil];
}

- (CGFloat)project:(CGFloat)initialVelocity decelerationRate:(CGFloat)decelerationRate {
    // From WWDC (UIScrollView.decelerationRate = 0.998)
    return (initialVelocity / 1000.0) * decelerationRate / (1.0 - decelerationRate);
}

- (void)_updateExpandedHeight:(CGFloat)height {
    // Calculate and update percent
    CGFloat fullHeight = self.contentViewController.fullyPresentedHeight;
    CGFloat expandedHeight = height - 150.0;
    CGFloat percent = expandedHeight / (fullHeight - 150);
    self.revealPercentage = percent;
}

@end