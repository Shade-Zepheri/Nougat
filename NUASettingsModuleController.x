#import "NUASettingsModuleController.h"
#import <SpringBoard/SBDateTimeController.h>
#import <SpringBoard/SBPreciseClockTimer.h>

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
        [self _settingsView].date = [%c(SBPreciseClockTimer) now];
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

- (void)setPresentedHeight:(CGFloat)presentedHeight {
    _presentedHeight = presentedHeight;

    if (presentedHeight == 0.0) {
        // Reset on 0
        presentedHeight = 150.0;
    } else if (presentedHeight < 150.0 || presentedHeight > 500.0) {
        // Dont do anything on first stage
        return;
    }

    CGFloat percentage = (0.002857 * presentedHeight) - 0.428571;
    [self _settingsView].expandedPercent = percentage;
}

#pragma mark - delegate

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
            [self _settingsView].date = [%c(SBPreciseClockTimer) now];
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

    SBPreciseClockTimer *timer = [%c(SBPreciseClockTimer) sharedInstance];
    [timer stopMinuteUpdatesForToken:_timerToken];
    _timerToken = nil;
}

- (void)_startUpdateTimer {
    if (_timerToken) {
        return;
    }

    SBPreciseClockTimer *timer = [%c(SBPreciseClockTimer) sharedInstance];
    _timerToken = [timer startMinuteUpdatesWithHandler:^{
        [self _updateTime];
    }];
}

@end