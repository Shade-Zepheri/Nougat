#import "NUADrawerViewController.h"
#import "NUAPreferenceManager.h"
#import "headers.h"

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
    /*
    [self configureMainView];
    [self loadToggles];
    */
}

- (void)configureView {
    self.view.frame = CGRectMake(0, -kScreenHeight / 1.5, kScreenWidth, kScreenHeight / 1.5);
    self.view.backgroundColor = [NUAPreferenceManager sharedSettings].backgroundColor;

    SBHomeScreenWindow *homescreenWindow = [[objc_getClass("SBUIController") sharedInstance] window];
    [homescreenWindow addSubview:self.view];
}

- (void)configureQuickToggles {
    CGFloat y = CGRectGetHeight(self.view.frame);
    self.quickTogglesView = [[UIView alloc] initWithFrame:CGRectMake(0, y - 50, kScreenWidth, 50)];
    self.quickTogglesView.backgroundColor = [UIColor clearColor];
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

- (void)handleHideDrawerGesture:(UIGestureRecognizer*)recognizer {
    HBLogDebug(@"UIGestureRecognizerState: %@", recognizer);
}

@end
