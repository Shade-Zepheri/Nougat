#import "NUAModulesContainerViewController.h"
#import "NUANotificationShadePanelView.h"

@implementation NUAModulesContainerViewController

#pragma mark - View management

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
    _brightnessModule.presentedHeight = 150.0;
    _settingsModule.presentedHeight = 150.0;
}

#pragma mark - Delegate

- (void)moduleWantsNotificationShadeDismissal:(NUANotificationShadeModuleViewController *)module completely:(BOOL)completely {
    [self.delegate contentViewControllerWantsDismissal:self completely:completely];
}

- (void)moduleWantsNotificationShadeExpansion:(NUANotificationShadeModuleViewController *)module {
    [self.delegate contentViewControllerWantsExpansion:self];
}

- (CGFloat)moduleWantsNotificationShadeFullyPresentedHeight:(NUANotificationShadeModuleViewController *)module {
    return [self.delegate contentViewControllerWantsFullyPresentedHeight:self];
}

- (void)setPresentedHeight:(CGFloat)height {
    _presentedHeight = height;

    // Pass height to toggles
    _brightnessModule.presentedHeight = height;
    _togglesModule.presentedHeight = height;
    _settingsModule.presentedHeight = height;
}

@end
