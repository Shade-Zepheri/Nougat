#import "NUADrawerViewController.h"
#import "NUAPreferenceManager.h"
#import "NUADrawerPanelButton.h"
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
    /*
    [self configureMainView];
    [self loadToggles];
    */
}

- (void)configureView {
    self.view.frame = CGRectMake(0, -kScreenHeight / 1.5, kScreenWidth, kScreenHeight / 1.5);
    self.view.backgroundColor = [NUAPreferenceManager sharedSettings].backgroundColor;

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
      UIView *view = [[NUADrawerPanelButton alloc] initWithFrame:CGRectMake(i * width, 0, width, 50) andSwitchIdentifier:_testArray[i]];
      [self.quickTogglesView addSubview:view];
    }
}

- (void)backgroundColorDidChange:(NSNotification *)note {
    self.view.backgroundColor = [NUAPreferenceManager sharedSettings].backgroundColor;
}

- (void)showQuickToggles:(BOOL)dismiss {
    CGFloat y = CGRectGetMidY(self.view.frame);
    if (dismiss) {
        y = -y;
    }
    [self.view addSubview:self.quickTogglesView];
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.quickTogglesView.alpha = 1;
        CGPoint center = CGPointMake(self.view.center.x, y + 50);
        self.view.center = center;
    } completion:nil];
}

- (void)showMainPanel {
    [UIView animateWithDuration:0.7 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.quickTogglesView.alpha = 0;
        self.view.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight / 1.5);
    } completion:nil];
}

- (void)dismissDrawer {
    CGFloat y = CGRectGetHeight(self.view.frame);
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.quickTogglesView.alpha = 0;
        self.view.frame = CGRectMake(0, -y, kScreenWidth, kScreenHeight / 1.5);
    } completion:nil];
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
            quickMenuVisible = NO;
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
