#import "NUASettingsModuleController.h"
#import <SpringBoardUIServices/SpringBoardUIServices.h>

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
    SBDateTimeController *controller = [%c(SBDateTimeController) sharedInstance];
    [controller addObserver:self];

    NSDate *overrideDate = controller.overrideDate;
    if (overrideDate) {
        [self _settingsView].date = overrideDate;
    } else {
        Class clockTimerClass = %c(SBUIPreciseClockTimer) ?: %c(SBPreciseClockTimer);
        [self _settingsView].date = [clockTimerClass now];
        if (!_disablesUpdates) {
            [self _startUpdateTimer];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // Start updates
    [self _setDisablesUpdates:NO];

    // Update date
    SBDateTimeController *controller = [%c(SBDateTimeController) sharedInstance];
    [self _settingsView].date = controller.currentDate;
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

#pragma mark - View management

- (void)_updateTime {
    if (_disablesUpdates) {
      [self _stopUpdateTimer];
    } else {
        SBDateTimeController *controller = [%c(SBDateTimeController) sharedInstance];
        [controller addObserver:self];

        NSDate *overrideDate = controller.overrideDate;
        if (overrideDate) {
            [self _settingsView].date = overrideDate;
        } else {
            Class clockTimerClass = %c(SBUIPreciseClockTimer) ?: %c(SBPreciseClockTimer);
            [self _settingsView].date = [clockTimerClass now];
            [self _startUpdateTimer];
        }
    }
}

#pragma mark - Time management

- (void)controller:(SBDateTimeController *)controller didChangeOverrideDateFromDate:(NSDate *)date {
    NSDate *overrideDate = controller.overrideDate;
    if (overrideDate) {
        [self _stopUpdateTimer];
    } else if (!_disablesUpdates) {
        [self _startUpdateTimer];
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
    // Probably not a retain cycle but lets play it safe
    __weak __typeof(self) weakSelf = self;
    _timerToken = [timer startMinuteUpdatesWithHandler:^{
        [weakSelf _updateTime];
    }];
}

@end