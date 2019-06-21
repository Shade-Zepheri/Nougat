#import "NUANotificationShadePageContainerViewController.h"
#import "NUADisplayLink.h"
#import <UIKit/UIPanGestureRecognizer+Internal.h>
#import <Macros.h>

@implementation NUANotificationShadePageContainerViewController

#pragma mark - Initialization

- (instancetype)initWithContentViewController:(UIViewController<NUANotificationShadePageContentProvider> *)viewController andDelegate:(id<NUANotificationShadePageContainerViewControllerDelegate>)delegate {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
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

#pragma mark - Delegate

- (CGFloat)presentedHeight {
    return self.contentViewController.presentedHeight;
}

- (void)setPresentedHeight:(CGFloat)height {
    // Pass on to content vc
    self.contentViewController.presentedHeight = height;
    // Pass on to panel
    [self _panelView].height = height;
}

- (void)contentViewControllerWantsDismissal:(UIViewController *)contentViewController completely:(BOOL)completely {
    [self.delegate containerViewControllerWantsDismissal:self completely:completely];
}

- (void)contentViewControllerWantsExpansion:(UIViewController *)contentViewController {
    [self.delegate containerViewControllerWantsExpansion:self];
}

- (CGFloat)contentViewControllerWantsFullyPresentedHeight:(UIViewController *)contentViewController {
    return [self.delegate containerViewControllerFullyPresentedHeight:self];
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
            _initialHeight = panel.height;
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
            [self _updatePresentedHeight:_initialHeight];
            break;
    }
}

- (void)_expandHeightWithTranslation:(CGPoint)translation {
    CGFloat newHeight = _initialHeight + translation.y;
    CGFloat fullHeight = self.contentViewController.completeHeight;
    if (newHeight > fullHeight) {
        // Apply slowdown
        newHeight = fullHeight + (newHeight - fullHeight) * 0.1;
    } else if (newHeight < 150.0) {
        newHeight = 150.0 - (150.0 - newHeight) * 0.1;
    }

    [self _updatePresentedHeight:newHeight];
}

- (void)_endExpansionWithTranslation:(CGPoint)translation velocity:(CGPoint)velocity {
    CGFloat newHeight = _initialHeight + translation.y;
    CGFloat projectedHeight = newHeight + [self project:velocity.y decelerationRate:0.998];

    CGFloat fullHeight = self.contentViewController.completeHeight;
    CGFloat expandTargetHeight = fullHeight * 0.7;
    CGFloat collapseTargetHeight = 150.0 * 1.4;

    CGFloat targetHeight = _initialHeight;
    if (projectedHeight >= expandTargetHeight) {
        // Expand
        targetHeight = fullHeight;
    } else if (projectedHeight <= collapseTargetHeight) {
        // Collapse
        targetHeight = 150.0;
    }

    [self _updatePresentedHeightGradually:targetHeight baseHeight:self.presentedHeight];
}

- (CGFloat)project:(CGFloat)initialVelocity decelerationRate:(CGFloat)decelerationRate {
    // From WWDC (UIScrollView.decelerationRate = 0.998)
    return (initialVelocity / 1000.0) * decelerationRate / (1.0 - decelerationRate);
}

CGFloat multiplerAdjustedWithEasing(CGFloat t) {
    // Use material design spec bezier curve to get multiplier
    CGFloat xForT = (0.6 * (1 - t) * t * t) + (1.2 * (1 - t) * (1 - t) * t) + ((1 - t) * (1 - t) * (1 - t));
    CGFloat yForX = (3 * xForT * xForT * (1 - xForT)) + (xForT * xForT * xForT);
    return 1 - yForX;
}

- (void)_updatePresentedHeightGradually:(CGFloat)targetHeight baseHeight:(CGFloat)baseHeight {
    __block NSInteger fireTimes = 0;
    __block CGFloat difference = targetHeight - baseHeight;

    __weak __typeof(self) weakSelf = self;
    [NUADisplayLink displayLinkWithBlock:^(CADisplayLink *displayLink) {
        if (fireTimes == 20) {
            [displayLink invalidate];
            [weakSelf _updatePresentedHeight:targetHeight];

            return;
        }

        
        fireTimes++;
        CGFloat t = fireTimes / 21.0;
        CGFloat multiplier = multiplerAdjustedWithEasing(t);

        // Update height
        CGFloat newHeight = baseHeight + (difference * multiplier);
        [weakSelf _updatePresentedHeight:newHeight];
    }];
}

- (void)_updatePresentedHeight:(CGFloat)height {
    self.presentedHeight = height;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // Only allow touch inside of panel
    CGPoint location = [touch locationInView:self.view];
    return CGRectContainsPoint(self.view.frame, location);
}

@end