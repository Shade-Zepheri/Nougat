#import "NUANotificationEntry.h"

@implementation NUANotificationEntry

#pragma mark - Init

+ (instancetype)notificationEntryWithTitle:(NSString *)title message:(NSString *)message timestamp:(NSDate *)timestamp {
    return [[self alloc] initWithTitle:title message:message timestamp:timestamp];
}

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message timestamp:(NSDate *)timestamp {
    self = [super init];
    if (self) {
        _title = title;
        _message = message;
        _timestamp = timestamp;
    }

    return self;
}

@end