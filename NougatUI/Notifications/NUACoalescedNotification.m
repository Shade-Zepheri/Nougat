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

#pragma mark - NSObject

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p; sectionID = %@; threadID = %@; title = %@; message = %@; entries = %@>", self.class, self, self.sectionID, self.threadID, self.title, self.message, self.entries];
}

- (BOOL)isEqual:(id)object {
    if (!object || ![object isKindOfClass:self.class]) {
        // Not same class
        return NO;
    }

    NUACoalescedNotification *notification = (NUACoalescedNotification *)object;
    if (notification.type == NUANotificationTypeMedia && self.type == NUANotificationTypeMedia) {
        // Dealing with media notifications, always equal
        return YES;
    }

    // Compare section, thread, title, message and entries
    BOOL sameSection = [notification.sectionID isEqualToString:self.sectionID];
    BOOL sameThread = [notification.threadID isEqualToString:self.threadID];
    BOOL sameTitle = [notification.title isEqualToString:self.title];
    BOOL sameMessage = [notification.message isEqualToString:self.message];
    BOOL sameEntries = [notification.entries isEqualToArray:self.entries];

    return sameSection && sameThread  && sameTitle && sameMessage && sameEntries;
}

- (NSComparisonResult)compare:(NUACoalescedNotification *)otherNotification {
    if (self.type == NUANotificationTypeMedia) {
        // We are the media notification, always be first
        return NSOrderedAscending;
    } else if (otherNotification.type == NUANotificationTypeMedia) {
        // Other notification is media, it must be first
        return NSOrderedDescending;
    } else {
        // Just compare timestamps
        return [otherNotification.timestamp compare:self.timestamp];
    }
}

#pragma mark - Properties

- (NSString *)title {
    if (!self.entries || self.empty) {
        // No entries
        return @"Title";
    }

    NSString *title = self.entries.firstObject.title;
    if (!title) {
        // No title
        return @"";
    }

    return title;
}

- (NSString *)message {
    if (!self.entries || self.empty) {
        return @"Message";
    }

    NSString *message = self.entries.firstObject.message;
    if (!message) {
        // No title
        return @"Message";
    }

    return message;
}

- (UIImage *)icon {
    UIImage *backupIcon = [UIImage _applicationIconImageForBundleIdentifier:@"com.apple.Preferences" format:0 scale:[UIScreen mainScreen].scale];
    if (!self.entries || self.empty) {
        return backupIcon;
    }

    UIImage *icon = self.entries.firstObject.icon;
    if (!icon) {
        // No title
        return backupIcon;
    }

    return icon;
}

- (UIImage *)attachmentImage {
    if (!self.entries || self.empty) {
        return nil;
    }

    return self.entries.firstObject.attachmentImage;
}

- (NSDate *)timestamp {
    if (!self.entries || self.empty) {
        return [NSDate date];
    }

    NSDate *timestamp = self.entries.firstObject.timestamp;
    if (!timestamp) {
        // No title
        return [NSDate date];
    }

    return timestamp;
}

- (NSTimeZone *)timeZone {
    if (!self.entries || self.empty) {
        return nil;
    }

    return self.entries.firstObject.timeZone;
}

- (BOOL)isEmpty {
    return self.entries.count < 1;
}

#pragma mark - Requests

- (BOOL)containsRequest:(NCNotificationRequest *)request {
    for (NUANotificationEntry *entry in self.entries) {
        // Since isEqual is too picky, i hate apple sometimes man
        if (![entry.request matchesRequest:request]) {
            continue;
        }

        return YES;
    }

    // Default no
    return NO;
}

- (void)updateWithNewRequest:(NCNotificationRequest *)request {
    if ([self containsRequest:request]) {
        // Already has request
        return;
    }

    // Construct entry
    NUANotificationEntry *entry = [NUANotificationEntry notificationEntryFromRequest:request];

    // Add to entries
    NSMutableArray<NUANotificationEntry *> *entries = [self.entries mutableCopy];
    [entries addObject:entry];

    // Sort entires
    [entries sortUsingComparator:^(NUANotificationEntry *entry1, NUANotificationEntry *entry2) {
        return [entry1 compare:entry2];
    }];

    _entries = [entries copy];
}

- (void)removeRequest:(NCNotificationRequest *)request {
    if (![self containsRequest:request]) {
        // Cant remove something i dont have
        return;
    }

    NSMutableArray<NUANotificationEntry *> *entries = [self.entries mutableCopy];
    for (NUANotificationEntry *entry in [entries reverseObjectEnumerator]) {
        // Reversed so no problemo
        if (![entry.request matchesRequest:request]) {
            // Doesnt have it
            continue;
        }

        // Remove object
        [entries removeObject:entry];
    }

    _entries = [entries copy];
}

@end