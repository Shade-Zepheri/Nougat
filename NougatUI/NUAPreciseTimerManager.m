#import "NUAPreciseTimerManager.h"

@interface NUAPreciseTimerManager ()
@property (strong, nonatomic) NSHashTable<id<NUAPreciseTimerManagerObserver>> *observers;
@property (strong, nonatomic) NSCalendar *calendar;
@property (strong, nonatomic) NSTimer *timer;

@property (nonatomic) NSInteger lastHour;
@property (nonatomic) NSInteger lastMinute;

@end

@implementation NUAPreciseTimerManager

#pragma mark - Init

+ (instancetype)sharedManager {
    static NUAPreciseTimerManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });

    return sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.observers = [NSHashTable weakObjectsHashTable];
        self.calendar = [NSCalendar autoupdatingCurrentCalendar];
        self.lastHour = 999;
        self.lastMinute = 999;
    }

    return self;
}

- (void)dealloc {
    [self _invalidateTimer];
}

#pragma mark - Timer

- (void)_invalidateTimer {
    // Invalidate and nil timer
    [self.timer invalidate];
    self.timer = nil;
}

- (void)_createTimerWithInterval:(NSTimeInterval)interval {
    __weak __typeof(self) weakSelf = self;
    self.timer = [NSTimer timerWithTimeInterval:interval repeats:YES block:^(NSTimer *timer) {
        [weakSelf _updateTime];
    }];

    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)_evaluateEnablement {
    if (self.observers.count == 0 && self.timer) {
        // Disable
        [self _invalidateTimer];
    } else if (!self.timer) {
        // Create
        [self _createTimerWithInterval:5];
    }
}

- (void)_updateTime {
    NSDate *now = [NSDate date];
    NSInteger hour;
    NSInteger minute;
    NSInteger second;
    [self.calendar getHour:&hour minute:&minute second:&second nanosecond:NULL fromDate:now];

    if (self.lastHour != hour || self.lastMinute != minute) {
        // Theres a change
        [self notifyObserversOfNewDate:now];

        self.lastHour = hour;
        self.lastMinute = minute;
    }

    // Update interval
    [self _updateTimerIntervalForOverflow:second];
}

- (void)_updateTimerIntervalForOverflow:(CGFloat)overflow {
    // Change interval to match 
    NSTimeInterval timeInterval = 60 - overflow;

    if (timeInterval == self.timer.timeInterval) {
        // No change
        return;
    }

    // Recreate timer
    [self _invalidateTimer];
    [self _createTimerWithInterval:timeInterval];
}

#pragma mark - Observers

- (void)addObserver:(id<NUAPreciseTimerManagerObserver>)observer {
    if ([self.observers containsObject:observer]) {
        return;
    }

    [self.observers addObject:observer];

    // Enable if needed
    [self _evaluateEnablement];
}

- (void)removeObserver:(id<NUAPreciseTimerManagerObserver>)observer {
    if (![self.observers containsObject:observer]) {
        return;
    }

    [self.observers removeObject:observer];

    // Disable if not needed
    [self _evaluateEnablement];
}

- (void)notifyObserversOfNewDate:(NSDate *)date {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (id<NUAPreciseTimerManagerObserver> observer in self.observers) {
            [observer managerUpdatedWithDate:date];
        }
    });
}

@end