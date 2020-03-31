#import "NUANotificationShadePageContainerViewController.h"
#import "NUADisplayLink.h"
#import <UIKit/UIKit+Private.h>
#import <Macros.h>

@interface NUANotificationShadePageContainerViewController ()
@property (getter=isDismissing, assign, nonatomic) BOOL dismissing;

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

#pragma mark - View management

- (void)loadView {
    NUANotificationShadePanelView *panelView = [[NUANotificationShadePanelView alloc] initWithDefaultSize];
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

- (void)setRevealPercentage:(CGFloat)percentage {
    // Pass to views
    self.contentViewController.revealPercentage = percentage;
    [self _panelView].revealPercentage = percentage;

    // Pass to delegate
    [self.delegate containerViewController:self updatedRevealPercentage:percentage];
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
    CGFloat fullHeight = self.contentViewController.fullyPresentedHeight;
    [self _updateExpandedHeight:fullHeight baseHeight:self.presentedHeight completion:nil];
}

- (CGFloat)contentViewControllerRequestsInteractiveHeight:(UIViewController *)contentViewController {
    return [self.delegate containerViewControllerRequestsInteractiveHeight:self];
}

- (void)handleDismiss {
    // Allow dispatching of delegate methods
    CGFloat baseHeight = CGRectGetHeight(self.view.bounds);
    [self _updateExpandedHeight:150.0 baseHeight:baseHeight completion:nil];
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

#pragma mark - Helpers

- (CGFloat)_multiplerAdjustedWithEasing:(CGFloat)t {
    // Use material design spec bezier curve to get multiplier
    CGFloat xForT = (0.6 * (1 - t) * t * t) + (1.2 * (1 - t) * (1 - t) * t) + ((1 - t) * (1 - t) * (1 - t));
    CGFloat yForX = (3 * xForT * xForT * (1 - xForT)) + (xForT * xForT * xForT);
    return 1 - yForX;
}

- (void)_updateExpandedHeight:(CGFloat)targetHeight baseHeight:(CGFloat)baseHeight completion:(void(^)(void))completion {
    // Pass through
    [self _updateHeightGradually:targetHeight baseHeight:baseHeight expand:YES completion:completion];
}

- (void)_updatePresentedHeight:(CGFloat)targetHeight baseHeight:(CGFloat)baseHeight completion:(void(^)(void))completion {
    // Pass through
    [self _updateHeightGradually:targetHeight baseHeight:baseHeight expand:NO completion:completion];
}

- (void)_updateHeightGradually:(CGFloat)targetHeight baseHeight:(CGFloat)baseHeight expand:(BOOL)expand completion:(void(^)(void))completion {
    __block NSInteger fireTimes = 0;
    __block CGFloat difference = targetHeight - baseHeight;

    __weak __typeof(self) weakSelf = self;
    [NUADisplayLink displayLinkWithBlock:^(CADisplayLink *displayLink) {
        if (fireTimes == 20) {
            [displayLink invalidate];

            if (expand) {
                [weakSelf _updateExpandedHeight:targetHeight];
            } else {
                [weakSelf _updatePresentedHeight:targetHeight];
            }

            if (completion) {
                completion();
            }

            return;
        }
        
        fireTimes++;
        CGFloat t = fireTimes / 21.0;
        CGFloat multiplier = [weakSelf _multiplerAdjustedWithEasing:t];

        // Update proper height
        CGFloat newHeight = baseHeight + (difference * multiplier);

        if (expand) {
            [weakSelf _updateExpandedHeight:newHeight];
        } else {
            [weakSelf _updatePresentedHeight:newHeight];
        }
    }];
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

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // Only allow touch inside of panel
    CGPoint location = [touch locationInView:self.view];
    return CGRectContainsPoint(self.view.frame, location);
}

@end