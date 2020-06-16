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

    // Register for notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferencesDidChange:) name:@"NUANotificationShadeChangedPreferences" object:nil];
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

- (void)_regenerateToggles {
    // Repopulate the toggles
    [self _tearDownCurrentToggles];
    [self _populateToggles];
}

- (void)_populateToggles {
    // Construct a sorted toggles list
    NSArray<NUAToggleInstance *> *toggleInstances = self.togglesProvider.toggleInstances;
    NSArray<NSString *> *orderedEnabledIdentifiers = self.notificationShadePreferences.enabledToggleIdentifiers;

    // Construct initial array
    NSMutableArray<NUAToggleButton *> *sortedTogglesList = [NSMutableArray array];
    for (NUAToggleInstance *toggleInstance in toggleInstances) {
        [sortedTogglesList addObject:toggleInstance.toggle];
    }

    // Sort to be properly ordered
    for (NUAToggleInstance *toggleInstance in toggleInstances) {
        NUAToggleInfo *toggleInfo = toggleInstance.toggleInfo;
        NSUInteger index = [orderedEnabledIdentifiers indexOfObject:toggleInfo.toggleIdentifier];

        [sortedTogglesList replaceObjectAtIndex:index withObject:toggleInstance.toggle];
    }

    // Send to view
    [[self _togglesContentView] populateWithToggles:[sortedTogglesList copy]];
}

- (void)_tearDownCurrentToggles {
    // Simply call a teardown
    [[self _togglesContentView] tearDownCurrentToggles];
}

- (void)toggleInstancesChangedForToggleInstancesProvider:(NUAToggleInstancesProvider *)toggleInstancesProvider {
    // Refresh
    [self _regenerateToggles];
}

#pragma mark - Notifications

- (void)preferencesDidChange:(NSNotification *)notification {
    // Refresh
    [self _regenerateToggles];
}

@end