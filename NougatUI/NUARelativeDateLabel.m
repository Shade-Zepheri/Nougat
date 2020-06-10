#import "NUARelativeDateLabel.h"

@interface NUARelativeDateLabel () {
    BOOL _isCollectingUpdates;
    BOOL _needsUpdateFromCollecting;
    NSTimer *_updateTimer;
}

@end

@implementation NUARelativeDateLabel

#pragma mark - Class Methods

+ (NSCalendar *)_currentCalendar {
    return [NSCalendar autoupdatingCurrentCalendar];
}

#pragma mark - Init

- (instancetype)init {
    self = [super init];
    if (self) {
        // Set defaults
        _timeZoneRelativeStartDate = [NSDate date];

        // Register for notification
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_handleSignificantTimeChange:) name:UIApplicationSignificantTimeChangeNotification object:nil];
    }

    return self;
}

- (void)dealloc {
    // Reset
    [self _invalidateTimer];
    [self _resetProperties];
}

#pragma mark - Notifications

- (void)_handleSignificantTimeChange:(NSNotification *)notification {
    // Reset timer and update
    [self _invalidateTimer];

    [self update];
    [self _configureTimer];
}

#pragma mark - Reuse

- (void)prepareForReuse {
    // Reset everything
    [self removeFromSuperview];

    self.text = nil;
    [self _invalidateTimer];
    [self _resetProperties];
}

- (void)_resetProperties {
    // Reset properties
    _isCollectingUpdates = NO;
    _needsUpdateFromCollecting = NO;
    _timeZoneRelativeStartDate = nil;
}

#pragma mark - Setup

- (NSDate *)_localDateForDate:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone {
    if (!date) {
        // No base date
        return nil;
    }

    // Get components from proposed timezone
    NSCalendar *calendar = [self.class _currentCalendar];
    calendar.timeZone = timeZone;
    NSDateComponents *components = [calendar components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:date];

    // Convert to system timezone
    calendar.timeZone = [NSTimeZone systemTimeZone];
    NSDate *localDate = [calendar dateFromComponents:components];

    return localDate ?: date;
}

- (void)setTimeZoneRelativeStartDate:(NSDate *)relativeStartDate absoluteStartDate:(NSDate *)absoluteStartDate {
    if ([self.timeZoneRelativeStartDate isEqualToDate:relativeStartDate]) {
        // Proposed date is the same as the stored date
        return;
    }

    // Update date
    _timeZoneRelativeStartDate = relativeStartDate;

    // Configure and update
    [self update];
    [self _configureTimer];
}

- (void)setStartDate:(NSDate *)startDate withTimeZone:(NSTimeZone *)timeZone {
    NSDate *localizedDate;
    if (!timeZone) {
        // No timezone to orient around
        localizedDate = startDate;
    } else {
        localizedDate = [self _localDateForDate:startDate inTimeZone:timeZone];
    }

    // Set start date
    [self setTimeZoneRelativeStartDate:localizedDate absoluteStartDate:startDate];
}

#pragma mark - Timer

- (NSTimeInterval)_calculateIntervalFromStartDate:(NSDate *)startDate toDate:(NSDate *)toDate {
    NSDateComponents *dateComponents = [[self.class _currentCalendar] components:(NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:startDate toDate:toDate options:0];
    NSTimeInterval baseInterval = 0.0;

    NSInteger days = dateComponents.day;
    NSInteger hours = dateComponents.hour;
    NSInteger minutes = dateComponents.minute;
    NSInteger seconds = dateComponents.second;

    if (days > 0) {
        // Deduct hours from a clean day
        baseInterval += (86400 - (3600 * (hours + 1)));

        // Deduct minutes from a clean hour
        baseInterval += (3600 - (60 * (minutes + 1)));
    } else if (hours > 0) {
        // Deduct minutes from a clean hour
        baseInterval += (3600 - (60 * (minutes + 1)));
    }

    // Deduct seconds from a clean minute
    baseInterval += (60 - seconds);

    return baseInterval;
}

- (void)_configureTimer {
    // Figure out update time
    NSTimeInterval updateInterval = [self _calculateIntervalFromStartDate:self.timeZoneRelativeStartDate toDate:[NSDate date]];

    // Create timer
    _updateTimer = [NSTimer timerWithTimeInterval:updateInterval target:self selector:@selector(_updateTimerFired:) userInfo:nil repeats:NO];

    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopDefaultMode, ^{
        if (!_updateTimer.valid) {
            // Invalid timer
            return;
        }

        // Add to runloop
        [[NSRunLoop mainRunLoop] addTimer:_updateTimer forMode:NSRunLoopCommonModes];
    });
}

- (void)_invalidateTimer {
    // Invalidate and nil timer
    [_updateTimer invalidate];
    _updateTimer = nil;
}

- (void)_updateTimerFired:(NSTimer *)timer {
    // Update
    [self update];

    // Reset timer
    [self _invalidateTimer];
    [self _configureTimer];
}

#pragma mark - Update

- (void)startCollectingUpdates {
    _isCollectingUpdates = YES;
}

- (void)endCollectingUpdates {
    if (!_isCollectingUpdates) {
        // Already stopped collecting updates
        return;
    }

    _isCollectingUpdates = NO;
    if (!_needsUpdateFromCollecting) {
        // Doesnt need update
        return;
    }

    // Update
    [self _forceUpdate];
    _needsUpdateFromCollecting = NO;
}

- (void)_forceUpdate {
    // Force update label
    [self updateTextIfNecessary:YES];
}

- (void)update {
    if (_isCollectingUpdates) {
        // Dont update until configuration done
        _needsUpdateFromCollecting = YES;
    } else {
        // Actually Update
        [self _forceUpdate];
    }
}

#pragma mark - Lable Management

- (NSString *)constructLabelString {
    NSDateComponents *dateComponents = [[self.class _currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute fromDate:self.timeZoneRelativeStartDate toDate:[NSDate date] options:0];

    NSBundle *localizationBundle = [NSBundle bundleForClass:self.class];
    NSInteger days = dateComponents.day;
    if (days > 0) {
        NSString *baseFormat = [localizationBundle localizedStringForKey:@"RELATIVE_DATE_PAST_DAYS" value:@"%zdd" table:@"Localizable"];
        return [NSString stringWithFormat:baseFormat, days];
    }

    NSInteger hours = dateComponents.hour;
    if (hours > 0) {
        NSString *baseFormat = [localizationBundle localizedStringForKey:@"RELATIVE_DATE_PAST_HOURS" value:@"%zdh" table:@"Localizable"];
        return [NSString stringWithFormat:baseFormat, hours];
    }

    NSInteger minutes = dateComponents.minute;
    if (minutes > 0) {
        NSString *baseFormat = [localizationBundle localizedStringForKey:@"RELATIVE_DATE_PAST_MINUTES" value:@"%zdm" table:@"Localizable"];
        return [NSString stringWithFormat:baseFormat, minutes];
    } 

    return [localizationBundle localizedStringForKey:@"RELATIVE_DATE_PAST_SECONDS" value:@"now" table:@"Localizable"];
}

- (void)updateTextIfNecessary {
    // Queue an update
    [self updateTextIfNecessary:NO];
}

- (void)updateTextIfNecessary:(BOOL)force {
    if (!force && _isCollectingUpdates) {
        // Queue an update
        _needsUpdateFromCollecting = YES;
        return;
    }

    // Get string and update
    NSString *newText = [self constructLabelString];
    if ([self.text isEqualToString:newText]) {
        // Same text, return
        return;
    }

    // Set text and update
    self.text = newText;
    [self setNeedsDisplay];

    // Delegate
    if (!self.delegate) {
        return;
    }

    [self.delegate dateLabelDidChange:self];
}

@end