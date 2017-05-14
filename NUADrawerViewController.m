#import "NUADrawerViewController.h"
#import "NUAPreferenceManager.h"
#import "NUAQuickToggleButton.h"
#import "headers.h"

BOOL quickMenuVisible = NO;
BOOL mainPanelVisible = NO;

@implementation NUADrawerViewController
- (instancetype)init {
    self = [super init];
    if (self) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(backgroundColorDidChange:) name:@"Nougat/BackgroundColorChange" object:nil];

        //Eventually array will come from user decided prefs
        _testArray = @[@"wifi", @"cellular-data", @"bluetooth", @"do-not-disturb", @"flashlight", @"rotation-lock"];
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureView];
    [self configureQuickToggles];
    [self configureMainToggles];
    /*
    [self loadToggles];
    */
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    HBLogDebug(@"viewDidAppear");
}

- (void)configureView {
    self.view.frame = CGRectMake(0, -kScreenHeight / 1.5, kScreenWidth, kScreenHeight / 1.5);
    self.view.backgroundColor = [NUAPreferenceManager sharedSettings].backgroundColor;

    CGFloat y = CGRectGetHeight(self.view.frame);
    self.statusBar = [[NUAStatusBar alloc] initWithFrame:CGRectMake(0, y - 100, kScreenWidth, 32)];
    [self.view addSubview:self.statusBar];

    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.view];

    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleHideDrawerGesture:)];
    [self.view addGestureRecognizer:panGesture];
}

- (void)configureQuickToggles {
    CGFloat y = CGRectGetHeight(self.view.frame);
    self.quickTogglesView = [[UIView alloc] initWithFrame:CGRectMake(0, y - 50, kScreenWidth, 50)];

    for (int i = 0; i < _testArray.count; i++) {
      CGFloat width = kScreenWidth / 6;
      UIView *view = [[NUAQuickToggleButton alloc] initWithFrame:CGRectMake(i * width, 0, width, 50) andSwitchIdentifier:_testArray[i]];
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
}

- (void)showQuickToggles:(BOOL)dismiss {
    CGFloat y = CGRectGetMidY(self.view.frame);
    if (dismiss) {
        y = -y;
    }
    [self.view addSubview:self.quickTogglesView];
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.quickTogglesView.alpha = 1;
        CGPoint center = CGPointMake(self.view.center.x, y + 100);
        self.view.center = center;

        self.statusBar.center = CGPointMake(kScreenWidth / 2, self.view.frame.size.height - 84);
        self.togglesPanel.alpha = 0;
    } completion:nil];
}

- (void)showMainPanel {
    [UIView animateWithDuration:0.7 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.statusBar.center = CGPointMake(kScreenWidth / 2, 16);
        self.quickTogglesView.alpha = 0;
        self.view.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight / 1.5);

        self.togglesPanel.alpha = 1;
    } completion:nil];
}

- (void)dismissDrawer {
    CGFloat y = CGRectGetHeight(self.view.frame);
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.quickTogglesView.alpha = 0;
        self.view.frame = CGRectMake(0, -y, kScreenWidth, kScreenHeight / 1.5);
    } completion:nil];
    quickMenuVisible = NO;
    mainPanelVisible = NO;
}

- (void)handleHideDrawerGesture:(UIPanGestureRecognizer*)recognizer {
    if (recognizer.state != UIGestureRecognizerStateEnded) {
        return;
    }

    UIView *view = (UIView*)recognizer.view;
    CGPoint velocity = [recognizer velocityInView:view];

    if (velocity.y < 0) {
        if (!quickMenuVisible) {
            [self showQuickToggles:YES];
            quickMenuVisible = YES;
            mainPanelVisible = NO;
        } else {
            [self dismissDrawer];
        }
    } else {
        if (quickMenuVisible) {
            [self showMainPanel];
            quickMenuVisible = NO;
            mainPanelVisible = YES;
        }
    }
}

@end
