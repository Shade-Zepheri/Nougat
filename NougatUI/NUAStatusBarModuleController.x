#import "NUAStatusBarModuleController.h"
#import "NUAStatusBarContentView.h"
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

    // Register for notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_updateFormat) name:@"BSDateTimeCacheChangedNotification" object:nil];

    // Register for time updates    
    SBDateTimeController *controller = [%c(SBDateTimeController) sharedInstance];
    [controller addObserver:self];

    NSDate *overrideDate = controller.overrideDate;
    if (overrideDate) {
        [self statusBarView].date = overrideDate;
    } else {
        Class clockTimerClass = %c(SBUIPreciseClockTimer) ?: %c(SBPreciseClockTimer);
        [self statusBarView].date = [clockTimerClass now];
        if (!_disablesUpdates) {
            [self _startUpdateTimer];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // Register for more notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_updateBatteryState:) name:@"NUABatteryStatusDidChangeNotification" object:nil];

    // Start updates
    [self _setDisablesUpdates:NO];

    SBDateTimeController *controller = [%c(SBDateTimeController) sharedInstance];
    [self statusBarView].date = controller.currentDate;

    // Update Battery label
    CGFloat currentPercent = [[UIDevice currentDevice] batteryLevel];
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

#pragma mark - Time management

- (void)controller:(SBDateTimeController *)controller didChangeOverrideDateFromDate:(NSDate *)date {
    NSDate *overrideDate = controller.overrideDate;
    if (overrideDate) {
        [self _stopUpdateTimer];
    } else if (!_disablesUpdates) {
        [self _startUpdateTimer];
    }

    if (!_disablesUpdates) {
        [self _updateFormat];
    }
}

- (void)_setDisablesUpdates:(BOOL)disablesUpdates {
    if (_disablesUpdates == disablesUpdates) {
        return;
    }

    _disablesUpdates = disablesUpdates;

    if (_disablesUpdates) {
        [self _stopUpdateTimer];
    } else {
        SBDateTimeController *controller = [%c(SBDateTimeController) sharedInstance];
        NSDate *overrideDate = controller.overrideDate;
        if (overrideDate) {
            return;
        }

        [self _startUpdateTimer];
    }
}

- (void)_stopUpdateTimer {
    if (!_timerToken) {
        return;
    }

    Class clockTimerClass = %c(SBUIPreciseClockTimer) ?: %c(SBPreciseClockTimer);
    SBPreciseClockTimer *timer = [clockTimerClass sharedInstance];
    [timer stopMinuteUpdatesForToken:_timerToken];
    _timerToken = nil;
}

- (void)_startUpdateTimer {
    if (_timerToken) {
        return;
    }

    Class clockTimerClass = %c(SBUIPreciseClockTimer) ?: %c(SBPreciseClockTimer);
    SBPreciseClockTimer *timer = [clockTimerClass sharedInstance];
    _timerToken = [timer startMinuteUpdatesWithHandler:^{
        [self _updateTime];
    }];
}

#pragma mark - View management

- (void)_updateTime {
    if (_disablesUpdates) {
      [self _stopUpdateTimer];
    } else {
        SBDateTimeController *controller = [%c(SBDateTimeController) sharedInstance];
        [controller addObserver:self];

        NSDate *overrideDate = controller.overrideDate;
        if (overrideDate) {
            [self statusBarView].date = overrideDate;
        } else {
            Class clockTimerClass = %c(SBUIPreciseClockTimer) ?: %c(SBPreciseClockTimer);
            [self statusBarView].date = [clockTimerClass now];
            [self _startUpdateTimer];
        }
    }
}

#pragma mark - Notifications

- (void)_updateFormat {
    if (_disablesUpdates) {
        return;
    }

    [[self statusBarView] updateFormat];

    [self _updateTime];
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

@end