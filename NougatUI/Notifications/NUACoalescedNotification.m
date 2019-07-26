#import "NUACoalescedNotification.h"
#import <UIKit/UIImage+Private.h>

@implementation NUACoalescedNotification

#pragma mark - Init

+ (instancetype)mediaNotification {
    // Dummy entry so can distinguish from notifications
    NUACoalescedNotification *notification = [[self alloc] init];
    notification.type = NUANotificationTypeMedia;
    return notification;
}

+ (instancetype)coalescedNotificationWithSectionID:(NSString *)sectionID title:(NSString *)title message:(NSString *)message entires:(NSArray<NUANotificationEntry *> *)entries {
    return [[self alloc] initWithSectionID:sectionID title:title message:message entires:entries];
}

- (instancetype)initWithSectionID:(NSString *)sectionID title:(NSString *)title message:(NSString *)message entires:(NSArray<NUANotificationEntry *> *)entries {
    self = [super init];
    if (self) {
        _sectionID = sectionID;
        _title = title;
        _message = message;
        _entries = entries;

        _type = NUANotificationTypeNotification;
        _icon = [UIImage _applicationIconImageForBundleIdentifier:sectionID format:0 scale:[UIScreen mainScreen].scale];

    }

    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p; sectionID = %@; title = %@; message = %@>", self.class, self, self.sectionID, self.title, self.message];
}

#pragma mark - Properties

- (NSDate *)timestamp {
    if (!self.entries) {
        return nil;
    }

    return self.entries[0].timestamp;
}

@end