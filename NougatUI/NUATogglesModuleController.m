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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferencesDidChange:) name:@"NUANotificationShadeChangedPreferences" object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [[self _togglesContentView] _layoutToggles];
}

- (NUATogglesContentView *)_togglesContentView {
    return (NUATogglesContentView *)self.view;
}

#pragma mark - Properties

- (void)setRevealPercentage:(CGFloat)revealPercentage {
    _revealPercentage = revealPercentage;

    CGFloat defaultModuleHeight = [self.class defaultModuleHeight];
    CGFloat completeContainerHeight = [self.delegate moduleRequestsContainerHeightWhenFullyRevealed:self];
    CGFloat heightToAdd = (completeContainerHeight - 150.0) * revealPercentage;
    CGFloat brightnessHeight = defaultModuleHeight * revealPercentage;
    _heightConstraint.constant = defaultModuleHeight + heightToAdd - brightnessHeight;

    // Pass to view
    [self _togglesContentView].expandedPercent = revealPercentage;
}

#pragma mark - Delegate

- (void)contentViewWantsNotificationShadeDismissal:(NUATogglesContentView *)contentView {
    [self.delegate moduleWantsNotificationShadeDismissal:self completely:YES];
}

#pragma mark - Notifications

- (void)preferencesDidChange:(NSNotification *)notification {
    // Let view know
    [[self _togglesContentView] refreshToggleLayout];
}

@end