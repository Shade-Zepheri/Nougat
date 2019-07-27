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

+ (instancetype)coalescedNotificationFromNotification:(NCCoalescedNotification *)notification {
    return [[self alloc] initFromNotification:notification];
}

- (instancetype)initFromNotification:(NCCoalescedNotification *)notification {
    self = [super init];
    if (self) {
        _sectionID = notification.sectionIdentifier;
        _threadID = notification.threadIdentifier;
        _type = NUANotificationTypeNotification;

        // Construct entires
        NSMutableArray<NUANotificationEntry *> *entries = [NSMutableArray array];
        NSArray<NCNotificationRequest *> *notificationRequests = notification.notificationRequests;
        for (NCNotificationRequest *request in notificationRequests) {
            NUANotificationEntry *entry = [NUANotificationEntry notificationEntryFromRequest:request];
            [entries addObject:entry];
        }

        // Sort entires
        [entries sortUsingComparator:^(NUANotificationEntry *entry1, NUANotificationEntry *entry2) {
            return [entry2.timestamp compare:entry1.timestamp];
        }];
        _entries = entries;

        // Get ivars from content
        NCNotificationContent *content = notification.content;
        _title = content.title;
        _message = content.message;
    }

    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p; sectionID = %@; threadID = %@; title = %@; message = %@>", self.class, self, self.sectionID, self.threadID, self.title, self.message];
}

#pragma mark - Properties

- (UIImage *)icon {
    if (!self.entries) {
        return nil;
    }

    return self.entries[0].icon;
}

- (UIImage *)attachmentImage {
    if (!self.entries) {
        return nil;
    }

    return self.entries[0].attachmentImage;
}

- (NSDate *)timestamp {
    if (!self.entries) {
        return nil;
    }

    return self.entries[0].timestamp;
}

#pragma mark - Updates

- (void)updateWithNewEntry:(NUANotificationEntry *)entry {
    // Extra stuffs
    NSMutableArray<NUANotificationEntry *> *entries = [self.entries mutableCopy];
    [entries insertObject:entry atIndex:0];
    _entries = [entries copy];
}

@end