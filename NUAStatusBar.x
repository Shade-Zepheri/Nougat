#import "NUANotificationShadeController.h"
#import "NUAStatusBar.h"
#import "NUAPreferenceManager.h"
#import "Macros.h"
#import <SpringBoard/SBDateTimeController.h>
#import <SpringBoard/SBPreciseClockTimer.h>
#import <SpringBoard/SpringBoard.h>

@implementation NUAStatusBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _resourceBundle = [NSBundle bundleWithPath:@"/var/mobile/Library/Nougat-Resources.bundle"];

        _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, CGRectGetWidth(frame) / 2, CGRectGetHeight(frame))];
        self.dateLabel.font = [UIFont systemFontOfSize:14];
        self.dateLabel.textColor = [UIColor whiteColor];
        self.dateLabel.backgroundColor = [UIColor clearColor];
        self.dateLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.dateLabel];

        _dateFormatter = [[NSDateFormatter alloc] init];
        self.dateFormatter.dateFormat = @"h:mm a - EEE, MMM d";

        // Implementing logic from LS clock cuz efficiency (WHen this becomes a VC do in viewDidAppear)
        // Really complicated logic
        SBDateTimeController *controller = [%c(SBDateTimeController) sharedInstance];
        [controller addObserver:self];

        NSDate *overrideDate = controller.overrideDate;
        if (overrideDate) {
            [self updateTimeWithDate:overrideDate];
        } else {
            NSDate *date =[%c(SBPreciseClockTimer) now];
            [self updateTimeWithDate:date];
            if (!_disablesUpdates) {
                [self _startUpdateTimer];
            }
        }

        [self loadRight];
    }

    return self;
}

- (void)controller:(SBDateTimeController *)controller didChangeOverrideDateFromDate:(NSDate *)date {
    NSDate *overrideDate = controller.overrideDate;
    if (overrideDate) {
        [self _stopUpdateTimer];
    } else if (!_disablesUpdates) {
        [self _startUpdateTimer];
    }

    if (!_disablesUpdates) {
        [self _updateTime];
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

- (void)_updateTime {
    if (_disablesUpdates) {
      [self _stopUpdateTimer];
    } else {
        SBDateTimeController *controller = [%c(SBDateTimeController) sharedInstance];
        [controller addObserver:self];

        NSDate *overrideDate = controller.overrideDate;
        if (overrideDate) {
            [self updateTimeWithDate:overrideDate];
        } else {
            NSDate *date =[%c(SBPreciseClockTimer) now];
            [self updateTimeWithDate:date];
            [self _startUpdateTimer];
        }
    }
}

- (void)loadRight {
    UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    settingsButton.frame = CGRectMake(kScreenWidth / 1.3, 10, 20, 20);
    UIImage *settingsCog = [UIImage imageNamed:@"settings" inBundle:self.resourceBundle compatibleWithTraitCollection:nil];
    [settingsButton setImage:settingsCog forState:UIControlStateNormal];
    [settingsButton addTarget:self action:@selector(settingsButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:settingsButton];

    _toggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.toggleButton.frame = CGRectMake(kScreenWidth / 1.1, 10, 20, 20);
    UIImage *arrow = [UIImage imageNamed:@"showMain" inBundle:self.resourceBundle compatibleWithTraitCollection:nil];
    [self.toggleButton setImage:arrow forState:UIControlStateNormal];
    [self.toggleButton addTarget:self action:@selector(toggleButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.toggleButton];

}

- (void)settingsButtonTapped:(UIButton *)sender {
    [[NUANotificationShadeController defaultNotificationShade] dismissAnimated:YES];
    [(SpringBoard *)[UIApplication sharedApplication] launchApplicationWithIdentifier:@"com.apple.Preferences" suspended:NO];
}

- (void)toggleButtonTapped:(UIButton *)sender {
    if ([NUANotificationShadeController defaultNotificationShade].presentedState == NUANotificationShadePresentedStateMainPanel) {
        [[NUANotificationShadeController defaultNotificationShade] dismissAnimated:YES completely:NO];
    } else {
        [[NUANotificationShadeController defaultNotificationShade] presentAnimated:YES showQuickSettings:NO];
    }
}

- (void)updateToggle:(BOOL)toggled {
    NSString *arrowName = toggled ? @"dismissMain" : @"showMain";
    UIImage *arrow = [UIImage imageNamed:arrowName inBundle:self.resourceBundle compatibleWithTraitCollection:nil];
    [self.toggleButton setImage:arrow forState:UIControlStateNormal];
}

- (void)updateTimeWithDate:(NSDate *)date {
    NUALogCurrentMethod;

    NSString *dateString = [self.dateFormatter stringFromDate:[NSDate date]];
    self.dateLabel.text = dateString;
}

@end
