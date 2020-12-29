#import "NUASettingsModuleController.h"

@implementation NUASettingsModuleController

+ (Class)viewClass {
    return NUASettingsContentView.class;
}

- (NSString *)moduleIdentifier {
    return @"com.shade.nougat.settings";
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Register as delegate
    [self _settingsView].delegate = self;

    // Register for time updates    
    _timeManager = [NUAPreciseTimerManager sharedManager];
    [self _settingsView].date = [NSDate date];
    if (!_disablesUpdates) {
        [self _startTimeUpdates];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // Start updates
    [self _setDisablesUpdates:NO];

    // Update date
    [self _settingsView].date = [NSDate date];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    // Stop updates
    [self _setDisablesUpdates:YES];
}

- (NUASettingsContentView *)_settingsView {
    return (NUASettingsContentView *)self.view;
}

#pragma mark - Properties

- (void)setRevealPercentage:(CGFloat)percent {
    _revealPercentage = percent;

    // Pass to view
    [self _settingsView].expandedPercent = percent;
}

#pragma mark - Delegate

- (void)contentViewWantsNotificationShadeDismissal:(NUASettingsContentView *)contentView completely:(BOOL)completely {
    [self.delegate moduleWantsNotificationShadeDismissal:self completely:completely];
}

- (void)contentViewWantsNotificationShadeExpansion:(NUASettingsContentView *)contentView {
    [self.delegate moduleWantsNotificationShadeExpansion:self];
}

#pragma mark - View Management

- (void)_updateLabelWithDate:(NSDate *)date {
    if (_disablesUpdates) {
      [self _stopTimeUpdates];
    } else {
        [self _settingsView].date = date;
        [self _startTimeUpdates];
    }
}

#pragma mark - Time management

- (void)managerUpdatedWithDate:(NSDate *)date {
    // Pass to label
    [self _updateLabelWithDate:date];
}

- (void)_setDisablesUpdates:(BOOL)disablesUpdates {
    if (_disablesUpdates == disablesUpdates) {
        return;
    }

    _disablesUpdates = disablesUpdates;

    if (_disablesUpdates) {
        [self _stopTimeUpdates];
    } else {
        [self _startTimeUpdates];
    }
}

- (void)_stopTimeUpdates {
    // Remove self as observer
    [self.timeManager removeObserver:self];
}

- (void)_startTimeUpdates {
    // Add self as observer
    [self.timeManager addObserver:self];
}

@end