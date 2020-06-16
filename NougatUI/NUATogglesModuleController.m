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

    // Create toggles manager
    _togglesProvider = [[NUAToggleInstancesProvider alloc] initWithPreferences:self.notificationShadePreferences];
    [self.togglesProvider addObserver:self];

    [self _populateToggles];
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

#pragma mark - Toggles Provider

- (void)_populateToggles {
    // Get toggles list
    NSArray<NUAToggleInstance *> *toggleInstances = self.togglesProvider.toggleInstances;
    NSMutableArray<NUAToggleButton *> *toggleList = [NSMutableArray array];
    for (NUAToggleInstance *toggleInstance in toggleInstances) {
        NUAToggleButton *toggle = toggleInstance.toggle;
        [toggleList addObject:toggle];
    }

    // Send to view
    [[self _togglesContentView] populateWithToggles:[toggleList copy]];
}

- (void)_tearDownCurrentToggles {
    // Simply call a teardown
    [[self _togglesContentView] tearDownCurrentToggles];
}

- (void)toggleInstancesChangedForToggleInstancesProvider:(NUAToggleInstancesProvider *)toggleInstancesProvider {
    // Repopulate the toggles
    [self _tearDownCurrentToggles];
    [self _populateToggles];
}

@end