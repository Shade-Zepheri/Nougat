#import "NUADrawerViewController.h"
#import "NUAPreferenceManager.h"

@implementation NUADrawerViewController
- (instancetype)initWithNibName:(NSString *)name bundle:(NSBundle *)bundle {
    self = [super initWithNibName:name bundle:bundle];
    if (self) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(backgroundColorDidChange:) name:@"Nougat/BackgroundColorChange" object:nil];
    }

    return self;
}

- (void)loadView {
    [super loadView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    /*
    [self configureView]
    [self loadQuickToggles]
    [self loadMainView];
    [self loadToggles];
    */
}

- (void)backgroundColorDidChange:(NSNotification *)note {
    HBLogDebug(@"recieved NSNotification");
    self.view.backgroundColor = [NUAPreferenceManager sharedSettings].backgroundColor;
}

@end
