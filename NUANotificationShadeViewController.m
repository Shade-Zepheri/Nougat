#import "NUANotificationShadeViewController.h"
#import "NUAPreferenceManager.h"
#import "NUAQuickToggleButton.h"
#import "NUANotificationCenterInhibitor.h"
#import "Macros.h"
#import <UIKit/UIPanGestureRecognizer+Private.h>


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
    _containerView = [[NUANotificationShadeContainerView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _containerView.delegate = self;
    self.view = _containerView;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // create and add modules container
    [self _loadModulesContainer];

    // create gesture recognizer
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_handlePanGesture:)];
    _panGesture.maximumNumberOfTouches = 1;
    _panGesture.delegate = self;

    // Not sure what these do but Apple uses them so why not
    [_panGesture setValue:@NO forKey:@"failsPastMaxTouches"];
    [_panGesture _setHysteresis:20];

    [self.view addGestureRecognizer:_panGesture];
}

- (void)_loadModulesContainer {
    _modulesViewController = [[NUAModulesContainerViewController alloc] init];

    [self addChildViewController:_modulesViewController];
    [self.view addSubview:_modulesViewController.view];
    [_modulesViewController didMoveToParentViewController:self];
}

- (CGFloat)presentedHeight {
    return _containerView.presentedHeight;
}

- (void)setPresentedHeight:(CGFloat)height {
    // This is where all the animating is done actually
    _containerView.presentedHeight = height;
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

- (UIView *)notificationShadeForContainerView:(NUANotificationShadeContainerView *)containerView {
    return _modulesViewController.view;
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
