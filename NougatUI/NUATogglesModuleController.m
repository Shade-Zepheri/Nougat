#import "NUATogglesModuleController.h"

@implementation NUATogglesModuleController

+ (Class)viewClass {
    return NUATogglesContentView.class;
}

- (NSString *)moduleIdentifier {
    return @"com.shade.nougat.toggles";
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Set as delegate
    [self _togglesContentView].delegate = self;

    // Register for notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backgroundColorDidChange:) name:@"NUANotificationShadeChangedBackgroundColor" object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [[self _togglesContentView] _layoutToggles];
}

- (NUATogglesContentView *)_togglesContentView {
    return (NUATogglesContentView *)self.view;
}

#pragma mark - Properties

- (void)setRevealPercentage:(CGFloat)percent {
    _revealPercentage = percent;
;
    _heightConstraint.constant = (350.0 * percent) + 150.0;

    // Pass to view
    [self _togglesContentView].expandedPercent = percent;
}

#pragma mark - Delegate

- (void)contentViewWantsNotificationShadeDismissal:(NUATogglesContentView *)contentView {
    [self.delegate moduleWantsNotificationShadeDismissal:self completely:YES];
}

#pragma mark - Notifications

- (void)backgroundColorDidChange:(NSNotification *)notification {
    // Defer to view
    [[self _togglesContentView] refreshToggleLayout];
}

@end