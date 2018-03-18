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
    UIView *container = [[UIView alloc] initWithFrame:CGRectZero];
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
