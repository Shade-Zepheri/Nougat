#import "NUANotificationShadeViewController.h"
#import "NUAModulesContainerViewController.h"
#import <UIKit/UIPanGestureRecognizer+Internal.h>


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
    _containerView = [[NUANotificationShadeContainerView alloc] initWithFrame:CGRectZero andDelegate:self];
    _containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view = _containerView;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // create and add modules container
    [self _loadModulesContainer];

    // create gesture recognizer
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_handlePanGesture:)];
    _panGesture.maximumNumberOfTouches = 1;

    // Increase pan gesture tolerance and not fail past max touches
    _panGesture.failsPastMaxTouches = NO;
    _panGesture._hysteresis = 20.0;

    [self.view addGestureRecognizer:_panGesture];
    _panGesture.delegate = self;
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

    [self.view setNeedsLayout];
}

- (CGFloat)presentedHeight {
    return _containerView.presentedHeight;
}

- (void)setPresentedHeight:(CGFloat)height {
    // This is where all the animating is done actually
    _containerView.presentedHeight = height;
    _containerViewController.presentedHeight = height;
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

#pragma mark - Container view delegate

- (NUANotificationShadePanelView *)notificationPanelForContainerView:(NUANotificationShadeContainerView *)containerView {
    return [_containerViewController _panelView];
}

- (void)containerViewWantsDismissal:(NUANotificationShadeContainerView *)containerView {
    [self.delegate notificationShadeViewControllerWantsDismissal:self completely:YES];
}

#pragma mark - Page container view controller delegate

- (void)containerViewControllerWantsDismissal:(NUANotificationShadePageContainerViewController *)containerViewController completely:(BOOL)completely {
    [self.delegate notificationShadeViewControllerWantsDismissal:self completely:completely];
}

- (void)containerViewControllerWantsExpansion:(NUANotificationShadePageContainerViewController *)containerViewController {
    [self.delegate notificationShadeViewControllerWantsExpansion:self];
}

#pragma mark - Gesture

- (void)_handlePanGesture:(UIPanGestureRecognizer *)recognizer {
    // Defer the gesture to the main controller
    [self.delegate notificationShadeViewController:self handlePan:recognizer];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // Temporary
    return [self.delegate notificationShadeViewController:self canHandleGestureRecognizer:gestureRecognizer];
}

@end
