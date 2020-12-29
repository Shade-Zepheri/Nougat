#import "NUAStatusBarModuleController.h"
#import "NUAStatusBarContentView.h"
#import <SpringBoard/SpringBoard-Umbrella.h>
#import <SpringBoardUIServices/SpringBoardUIServices.h>

@implementation NUAStatusBarModuleController

+ (Class)viewClass {
    return NUAStatusBarContentView.class;
}

- (NSString *)moduleIdentifier {
    return @"com.shade.nougat.statusbar";
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Hide/Show view
    self.view.alpha = self.notificationShadePreferences.hideStatusBarModule ? 0.0 : 1.0;

    // Register for notifications
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(_updateFormat) name:@"BSDateTimeCacheChangedNotification" object:nil];
    [center addObserver:self selector:@selector(preferencesDidChange:) name:@"NUANotificationShadeChangedPreferences" object:nil];

    // Register for time updates
    _timeManager = [NUAPreciseTimerManager sharedManager];
    [self statusBarView].date = [NSDate date];
    if (!_disablesUpdates) {
        [self _startTimeUpdates];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // Register for battery updates
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_updateBatteryState:) name:@"NUABatteryStatusDidChangeNotification" object:nil];

    // Start updates
    [self _setDisablesUpdates:NO];

    [self statusBarView].date = [NSDate date];

    // Update Battery label
    CGFloat currentPercent = [UIDevice currentDevice].batteryLevel;
    [self statusBarView].currentPercent = currentPercent;

    BOOL isCharging = [[%c(SBUIController) sharedInstance] isBatteryCharging];
    [self statusBarView].charging = isCharging;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    // Deregister from notification
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NUABatteryStatusDidChangeNotification" object:nil];

    // Stop updates
    [self _setDisablesUpdates:YES];
}

- (NUAStatusBarContentView *)statusBarView {
    return (NUAStatusBarContentView *)self.view;
}

#pragma mark - Time Management

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

#pragma mark - View Management

- (void)_updateLabelWithDate:(NSDate *)date {
    if (_disablesUpdates) {
      [self _stopTimeUpdates];
    } else {
        [self statusBarView].date = date;
        [self _startTimeUpdates];
    }
}

#pragma mark - Notifications

- (void)_updateFormat {
    if (_disablesUpdates) {
        return;
    }

    [[self statusBarView] updateFormat];

    [self _updateLabelWithDate:[NSDate date]];
}

- (void)_updateBatteryState:(NSNotification *)notification {
    NSDictionary<NSString *, NSNumber *> *userInfo = notification.userInfo;

    BOOL isCharging = userInfo[@"IsCharging"].boolValue;
    CGFloat currentCapacity = userInfo[@"CurrentCapacity"].floatValue;
    CGFloat maxCapacity = userInfo[@"MaxCapacity"].floatValue;
    CGFloat currentPercent = (currentCapacity / maxCapacity);

    [self statusBarView].currentPercent = currentPercent;
    [self statusBarView].charging = isCharging;
}

- (void)preferencesDidChange:(NSNotification *)notification {
    // Hide/Show view
    self.view.alpha = self.notificationShadePreferences.hideStatusBarModule ? 0.0 : 1.0;
}

@end