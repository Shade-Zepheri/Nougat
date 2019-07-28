#import "NUACoalescedNotification.h"
#import "NSArray+Map.h"
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
    }

    return self;
}

+ (instancetype)coalescedNotificationFromRequest:(NCNotificationRequest *)request {
    return [[self alloc] initFromRequest:request];
}

- (instancetype)initFromRequest:(NCNotificationRequest *)request {
    self = [super init];
    if (self) {
        // Most some of the properties are going to be nil but essentials rely on the entry
        _sectionID = request.sectionIdentifier;
        _threadID = request.threadIdentifier;
        _type = NUANotificationTypeNotification;

        // Construct entry
        NUANotificationEntry *entry = [NUANotificationEntry notificationEntryFromRequest:request];
        _entries = @[entry];
    }

    return self;
}

#pragma mark - Description

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p; sectionID = %@; threadID = %@; title = %@; message = %@>", self.class, self, self.sectionID, self.threadID, self.title, self.message];
}

#pragma mark - Properties

- (NSString *)title {
    if (!self.entries || self.entries.count < 1) {
        return nil;
    }

    return self.entries[0].title;
}

- (NSString *)message {
    if (!self.entries || self.entries.count < 1) {
        return nil;
    }

    return self.entries[0].message;
}

- (UIImage *)icon {
    if (!self.entries || self.entries.count < 1) {
        return nil;
    }

    return self.entries[0].icon;
}

- (UIImage *)attachmentImage {
    if (!self.entries || self.entries.count < 1) {
        return nil;
    }

    return self.entries[0].attachmentImage;
}

- (NSDate *)timestamp {
    if (!self.entries || self.entries.count < 1) {
        return nil;
    }

    return self.entries[0].timestamp;
}

#pragma mark - Requests

- (BOOL)containsRequest:(NCNotificationRequest *)request {
    NSArray<NUANotificationEntry *> *entries = self.entries;
    NSArray<NCNotificationRequest *> *requests = [entries map:^id(id obj) {
        return ((NUANotificationEntry *)obj).request;
    }];

    return [requests containsObject:request];
}

- (void)updateWithNewRequest:(NCNotificationRequest *)request {
    // Construct entry
    NUANotificationEntry *entry = [NUANotificationEntry notificationEntryFromRequest:request];

    // Add to entries
    NSMutableArray<NUANotificationEntry *> *entries = [self.entries mutableCopy];
    [entries insertObject:entry atIndex:0];
    _entries = [entries copy];
}

@end