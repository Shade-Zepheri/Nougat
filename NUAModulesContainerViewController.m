#import "NUAModulesContainerViewController.h"
#import "NUAPreferenceManager.h"
#import "Macros.h"

@implementation NUAModulesContainerViewController

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        // Register for notifications
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(backgroundColorDidChange:) name:@"NUANotificationShadeChangedBackgroundColor" object:nil];
    }

    return self;
}

#pragma mark - View management

- (void)loadView {
    // Create drawer container view
    CGRect frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight / 1.5);
    UIView *container = [[UIView alloc] initWithFrame:frame];
    container.backgroundColor = [NUAPreferenceManager sharedSettings].backgroundColor;
    self.view = container;

    // Create stackview
}

- (void)viewDidAppear:(BOOL)animated {

}

#pragma mark - Notifications

- (void)backgroundColorDidChange:(NSNotification *)notification {
    NSDictionary *colorInfo = notification.userInfo;
    self.view.backgroundColor = colorInfo[@"backgroundColor"];
}

@end
