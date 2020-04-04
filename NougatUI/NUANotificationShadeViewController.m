#import "NUANotificationShadeViewController.h"
#import "NUAModulesContainerViewController.h"
#import <UIKit/UIKit+Private.h>
#import <Macros.h>

@implementation NUANotificationShadeViewController

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        //Register for notifications
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(_noteNotificationShadeControlDidActivate:) name:@"NUANotificationShadeDidActivate" object:nil];
        [center addObserver:self selector:@selector(_noteNotificationShadeControlDidDeactivate:) name:@"NUANotificationShadeDidDeactivate" object:nil];
    }

    return self;
}

#pragma mark - View management

- (void)loadView {
    // Just like SB (create container view and make it self.view)
    _containerView = [[NUANotificationShadeContainerView alloc] initWithFrame:CGRectZero];
    _containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view = _containerView;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // create and add modules container
    [self _loadModulesContainer];

    // Load extensions table
    [self _loadExtensionsTable];

    // Add pan gesture recognizer
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_handlePanGesture:)];
    _panGesture.maximumNumberOfTouches = 1;

    // Increase pan gesture tolerance and not fail past max touches
    _panGesture.failsPastMaxTouches = NO;
    _panGesture._hysteresis = 20.0;

    [self.view addGestureRecognizer:_panGesture];
    _panGesture.delegate = self;

    // Add tap to dismiss
     _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleTapGesture:)];
    [self.view addGestureRecognizer:_tapGesture];
    _tapGesture.delegate = self;
}

- (void)_loadModulesContainer {
    NUAModulesContainerViewController *modulesViewController = [[NUAModulesContainerViewController alloc] initWithNibName:nil bundle:nil];
    _containerViewController = [[NUANotificationShadePageContainerViewController alloc] initWithContentViewController:modulesViewController andDelegate:self];

    if ([self.childViewControllers containsObject:_containerViewController]) {
        return;
    }

    [self addChildViewController:_containerViewController];
    [self.view addSubview:_containerViewController.view];
    [_containerViewController didMoveToParentViewController:self];

    // Add constraints instead of relying on viewWillLayoutSubviews to update frame
    [_containerViewController.view.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;

    // Constrain width on ipads or set width on phones to device width;
    CGFloat desiredWidth = MIN(414, kScreenWidth);
    [_containerViewController.view.widthAnchor constraintEqualToConstant:desiredWidth].active = YES;

    // Do something special with top because slide in from top
    NSLayoutConstraint *topConstraint = [_containerViewController.view.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:-150.0];
    topConstraint.active = YES;
    [_containerViewController _panelView].insetConstraint = topConstraint;

    [self.view setNeedsLayout];
}

- (void)_loadExtensionsTable {
    _tableViewController = [[NUAMainTableViewController alloc] init];
    self.tableViewController.delegate = self;

    // Add as child
    [self addChildViewController:self.tableViewController];
    [self.view addSubview:self.tableViewController.view];
    [self.tableViewController didMoveToParentViewController:self];

    // Constraint up
    [self.tableViewController.view.widthAnchor constraintEqualToAnchor:_containerViewController.view.widthAnchor].active = YES;

    [self.tableViewController.view.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.tableViewController.view.topAnchor constraintEqualToAnchor:_containerViewController.view.bottomAnchor].active  = YES;
}

- (BOOL)_canShowWhileLocked {
    // New on iOS 13
    return YES;
}

#pragma mark - Properties

- (CGFloat)presentedHeight {
    return _containerView.presentedHeight;
}

- (void)setPresentedHeight:(CGFloat)height {
    self.tableViewController.presentedHeight = height;
    _containerView.presentedHeight = height;
    _containerViewController.presentedHeight = height;
}

- (CGFloat)fullyPresentedHeight {
    // Get from tableview + panel
    return self.tableViewController.contentHeight + 150.0;
}

#pragma mark - Notifications

- (void)_noteNotificationShadeControlDidActivate:(NSNotification *)notification {
    // Get message and verify
    NSDictionary *info = notification.userInfo;
    NSString *message = info[@"NUANotificationShadeControlName"];

    if (![message isEqualToString:@"brightness"]) {
        return;
    }

    // If is brightness message, dim alpha
    _containerView.changingBrightness = YES;
}

- (void)_noteNotificationShadeControlDidDeactivate:(NSNotification *)notification {
    // Get message and verify
    NSDictionary *info = notification.userInfo;
    NSString *message = info[@"NUANotificationShadeControlName"];

    if (![message isEqualToString:@"brightness"]) {
        return;
    }

    // If is brightness message, restore alpha
    _containerView.changingBrightness = NO;
}

#pragma mark - Page container view controller delegate

- (void)containerViewControllerWantsDismissal:(NUANotificationShadePageContainerViewController *)containerViewController {
    [self.delegate notificationShadeViewControllerWantsDismissal:self];
}

- (CGFloat)containerViewControllerRequestsInteractiveHeight:(NUANotificationShadePageContainerViewController *)containerViewController {
    return [self.delegate notificationShadeViewControllerRequestsInteractiveHeight:self];
}

- (void)containerViewController:(NUANotificationShadePageContainerViewController *)containerViewController updatedPresentedHeight:(CGFloat)presentedHeight {
    // Pass to blur view
    _containerView.presentedHeight = presentedHeight;
    self.tableViewController.presentedHeight = presentedHeight;
}

- (void)containerViewController:(NUANotificationShadePageContainerViewController *)containerViewController updatedRevealPercentage:(CGFloat)revealPercentage {
    // Pass to table
    self.tableViewController.revealPercentage = revealPercentage;
}

#pragma mark - Table view delegate

- (void)tableViewControllerWantsDismissal:(NUAMainTableViewController *)tableViewController {
    [self.delegate notificationShadeViewControllerWantsDismissal:self];
}

- (CGFloat)tableViewControllerRequestsPanelContentHeight:(NUAMainTableViewController *)tableViewController {
    // Get content height
    return _containerViewController.contentPresentedHeight;
}

#pragma mark - Gestures

- (void)_handlePanGesture:(UIPanGestureRecognizer *)recognizer {
    if (_containerViewController.panelState == NUANotificationShadePanelStateExpanded) {
        // Don't invoke present gesture if panel is fully expanded
        return;
    }

    // Defer the gesture to the main controller
    [self.delegate notificationShadeViewController:self handlePan:recognizer];
}

- (void)_handleTapGesture:(UITapGestureRecognizer *)recognizer {
    // Defer the gesture to the main controller
    [_containerViewController handleDismiss:YES];
    [self.delegate notificationShadeViewController:self handleTap:recognizer];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // Check if gestures allowed
    BOOL allowGesture = [self.delegate notificationShadeViewController:self canHandleGestureRecognizer:gestureRecognizer];
    if (allowGesture) {
        CGPoint location = [touch locationInView:self.view];
        if (gestureRecognizer == _tapGesture) {
            // Check if inside panel
            CGRect panelFrame = [_containerViewController _panelView].frame;
            CGRect convertedPanelFrame = [[_containerViewController _panelView] convertRect:panelFrame toView:self.view];
            BOOL touchInsidePanel = CGRectContainsPoint(convertedPanelFrame, location);

            // Check if inside table
            CGRect tableFrame = self.tableViewController.view.frame;
            BOOL touchInsideTable = CGRectContainsPoint(tableFrame, location);
            allowGesture = !touchInsidePanel && !touchInsideTable;
        } else if (gestureRecognizer == _panGesture) {
            // Only allow dismiss when interacting outside of panel
            CGRect panelFrame = [_containerViewController _panelView].frame;
            CGRect convertedFrame = [[_containerViewController _panelView] convertRect:panelFrame toView:self.view];
            allowGesture = !CGRectContainsPoint(convertedFrame, location);
        }
    } else {
        allowGesture = NO;
    }

    return allowGesture;
}

#pragma mark - Animation Finishers

- (void)dismissAnimated:(BOOL)animated completion:(void(^)(void))completion {
    // Collapse panel
    [_containerViewController handleDismiss:animated];

    // Dismiss panel
    if (animated) {
        [self updateToFinalPresentedHeight:0 completion:completion];
    } else {
        self.presentedHeight = 0.0;

        if (completion) {
            completion();
        }
    }
}

- (void)updateToFinalPresentedHeight:(CGFloat)finalHeight completion:(void(^)(void))completion {
    [_containerViewController updateToFinalPresentedHeight:finalHeight completion:completion];
}

@end
