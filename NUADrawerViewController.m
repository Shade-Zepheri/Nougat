#import "NUADrawerViewController.h"
#import "NUAPreferenceManager.h"
#import "NUAQuickToggleButton.h"
#import "NUANotificationCenterInhibitor.h"
#import "headers.h"

BOOL quickMenuVisible = NO;
BOOL mainPanelVisible = NO;

@implementation NUADrawerViewController
- (instancetype)init {
    self = [super init];
    if (self) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(backgroundColorDidChange:) name:@"Nougat/BackgroundColorChange" object:nil];
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureView];
    [self configureQuickToggles];
    [self configureMainToggles];
}

- (void)configureView {
    self.view.frame = CGRectMake(0, -kScreenHeight / 1.5, kScreenWidth, kScreenHeight / 1.5);
    self.view.backgroundColor = [NUAPreferenceManager sharedSettings].backgroundColor;

    CGFloat y = CGRectGetHeight(self.view.frame);
    self.statusBar = [[NUAStatusBar alloc] initWithFrame:CGRectMake(0, y - 100, kScreenWidth, 32)];
    [self.view addSubview:self.statusBar];

    self.quickTogglesView = [[UIView alloc] initWithFrame:CGRectMake(0, y - 50, kScreenWidth, 50)];

    _UIBackdropViewSettings *blurSettings = [_UIBackdropViewSettings settingsForStyle:2030 graphicsQuality:100];
    self.backdropView = [[objc_getClass("_UIBackdropView") alloc] initWithFrame:[UIScreen mainScreen].bounds autosizesToFitSuperview:NO settings:blurSettings];
    self.backdropView.userInteractionEnabled = YES;
    self.backdropView.alpha = 0;

    self.window = [[NUAWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.window addSubview:self.view];
    [self.window insertSubview:self.backdropView belowSubview:self.view];

    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleHideDrawerGesture:)];
    [self.view addGestureRecognizer:panGesture];
}

- (void)configureQuickToggles {
    NSArray *toggleOrder = [NUAPreferenceManager sharedSettings].quickToggleOrder;
    for (int i = 0; i < toggleOrder.count; i++) {
      CGFloat width = kScreenWidth / 6;
      UIView *view = [[NUAQuickToggleButton alloc] initWithFrame:CGRectMake(i * width, 0, width, 50) andSwitchIdentifier:toggleOrder[i]];
      [self.quickTogglesView addSubview:view];
    }
}

- (void)configureMainToggles {
    self.togglesPanel = [[NUADrawerPanel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth - 50, kScreenWidth - 20)];
    self.togglesPanel.alpha = 0;

    CGSize size = self.view.frame.size;
    self.togglesPanel.center = CGPointMake(size.width / 2, (size.height / 2) + 10);
    [self.view addSubview:self.togglesPanel];
}

- (void)backgroundColorDidChange:(NSNotification *)note {
    NSDictionary *colorInfo = [note userInfo];
    self.view.backgroundColor = colorInfo[@"backgroundColor"];
    [self.togglesPanel updateTintTo:colorInfo[@"tintColor"]];

    [self.togglesPanel refreshTogglePanel];
    [self.quickTogglesView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self configureQuickToggles];
}

- (void)showQuickToggles:(BOOL)dismiss {
    CGFloat y = CGRectGetMidY(self.view.frame);
    if (dismiss) {
        y = -y;
    }
    [self.view addSubview:self.quickTogglesView];
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.backdropView.alpha = 1;
        self.quickTogglesView.alpha = 1;
        CGPoint center = CGPointMake(self.view.center.x, y + 100);
        self.view.center = center;

        self.statusBar.center = CGPointMake(kScreenWidth / 2, self.view.frame.size.height - 84);
        self.togglesPanel.alpha = 0;
    } completion:^(BOOL finished){
        [self.statusBar updateToggle:NO];
        quickMenuVisible = YES;
        mainPanelVisible = NO;
    }];
}

- (void)showMainPanel {
    [self.togglesPanel updateSliderValue];
    [UIView animateWithDuration:0.7 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.backdropView.alpha = 1;
        self.statusBar.center = CGPointMake(kScreenWidth / 2, 16);
        self.quickTogglesView.alpha = 0;
        self.view.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight / 1.5);

        self.togglesPanel.alpha = 1;
    } completion:^(BOOL finished){
        [self.statusBar updateToggle:YES];
        quickMenuVisible = NO;
        mainPanelVisible = YES;
    }];
}

- (void)dismissDrawer {
    CGFloat y = CGRectGetHeight(self.view.frame);
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.backdropView.alpha = 0;
        self.quickTogglesView.alpha = 0;
        self.view.frame = CGRectMake(0, -y, kScreenWidth, kScreenHeight / 1.5);
    } completion:^(BOOL finished){
        quickMenuVisible = NO;
        mainPanelVisible = NO;
        [NUANotificationCenterInhibitor setInhibited:NO];
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }];
}

- (void)handleHideDrawerGesture:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state != UIGestureRecognizerStateEnded) {
        return;
    }

    UIView *view = (UIView*)recognizer.view;
    CGPoint velocity = [recognizer velocityInView:view];

    if (velocity.y < 0) {
        if (!quickMenuVisible) {
            [self showQuickToggles:YES];
        } else {
            [self dismissDrawer];
        }
    } else {
        if (quickMenuVisible) {
            [self showMainPanel];
        }
    }
}

@end
