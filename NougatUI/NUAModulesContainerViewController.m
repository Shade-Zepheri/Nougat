#import "NUAModulesContainerViewController.h"

@implementation NUAModulesContainerViewController

#pragma mark - View Management

- (void)loadView {
    _moduleList = [NSMutableArray array];

    // Create stackview
    _verticalStackView = [[UIStackView alloc] initWithFrame:CGRectZero];
    _verticalStackView.axis = UILayoutConstraintAxisVertical;
    _verticalStackView.alignment = UIStackViewAlignmentFill;
    _verticalStackView.distribution = UIStackViewDistributionEqualSpacing;
    _verticalStackView.spacing = 0.0;
    _verticalStackView.translatesAutoresizingMaskIntoConstraints = NO;

    // Create modules
    _statusBarModule = [[NUAStatusBarModuleController alloc] init];
    _statusBarModule.delegate = self;
    [_moduleList addObject:_statusBarModule];

    _brightnessModule = [[NUABrightnessModuleController alloc] init];
    _brightnessModule.delegate = self;
    [_moduleList addObject:_brightnessModule];

    _togglesModule = [[NUATogglesModuleController alloc] init];
    _togglesModule.delegate = self;
    [_moduleList addObject:_togglesModule];

    _settingsModule = [[NUASettingsModuleController alloc] init];
    _settingsModule.delegate = self;
    [_moduleList addObject:_settingsModule];

    // Create view
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    [view addSubview:_verticalStackView];
    self.view = view;

    // Create constraints
    [_verticalStackView.topAnchor constraintEqualToAnchor:view.topAnchor].active = YES;
    [_verticalStackView.bottomAnchor constraintEqualToAnchor:view.bottomAnchor].active = YES;
    [_verticalStackView.leadingAnchor constraintEqualToAnchor:view.leadingAnchor].active = YES;
    [_verticalStackView.trailingAnchor constraintEqualToAnchor:view.trailingAnchor].active = YES;

    // Load modules
    [self _updateModules];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self _updateModules];
}

- (void)_updateModules {
    if (_verticalStackView.arrangedSubviews.count > 0) {
        return;
    }

    for (NUAModulesContainerViewController *moduleController in _moduleList) {
        [self addChildViewController:moduleController];
        [_verticalStackView addArrangedSubview:moduleController.view];
        [moduleController didMoveToParentViewController:self];
    }

    // Set default height to modules
    _brightnessModule.revealPercentage = 0.0;
    _settingsModule.revealPercentage = 0.0;
}

- (BOOL)_canShowWhileLocked {
    // New on iOS 13
    return YES;
}

#pragma mark - Properties

- (CGFloat)fullyPresentedHeight {
    NSUInteger togglesCount = self.notificationShadePreferences.enabledToggleIdentifiers.count;
    if (togglesCount > 6) {
        return 500.0;
    } else if (togglesCount > 3) {
        return 400.0;
    } else {
        return 300.0;
    }
}

- (void)setRevealPercentage:(CGFloat)revealPercentage {
    _revealPercentage = revealPercentage;

    // Pass percent to toggles
    _brightnessModule.revealPercentage = revealPercentage;
    _togglesModule.revealPercentage = revealPercentage;
    _settingsModule.revealPercentage = revealPercentage;
}

#pragma mark - Delegate

- (void)moduleWantsNotificationShadeDismissal:(NUANotificationShadeModuleViewController *)moduleViewController completely:(BOOL)completely {
    [self.delegate contentViewControllerWantsDismissal:self completely:completely];
}

- (void)moduleWantsNotificationShadeExpansion:(NUANotificationShadeModuleViewController *)moduleViewController {
    [self.delegate contentViewControllerWantsExpansion:self];
}

- (CGFloat)moduleRequestsContainerHeightWhenFullyRevealed:(NUANotificationShadeModuleViewController *)moduleViewController {
    return self.fullyPresentedHeight;
}

- (NUAPreferenceManager *)notificationShadePreferences {
    return self.delegate.notificationShadePreferences;
}

- (id<NUASystemServicesProvider>)systemServicesProvider {
    return self.delegate.systemServicesProvider;
}

@end
