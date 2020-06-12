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
            return [entry1 compare:entry2];
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
        return nil;
    }

    NSString *title = self.leadingNotificationEntry.title;
    if (!title) {
        // No title
        return nil;
    }

    return title;
}

- (NSString *)message {
    if (!self.entries || self.empty) {
        return @"Message";
    }

    NSString *message = self.leadingNotificationEntry.message;
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

    UIImage *icon = self.leadingNotificationEntry.icon;
    if (!icon) {
        // No title
        return backupIcon;
    }

    return icon;
}

- (BOOL)hasAttachmentImage {
    if (!self.entries || self.empty) {
        return NO;
    }

    return self.leadingNotificationEntry.hasAttachmentImage;
}

- (UIImage *)attachmentImage {
    if (!self.entries || self.empty) {
        return nil;
    }

    return self.leadingNotificationEntry.attachmentImage;
}

- (NSDate *)timestamp {
    if (!self.entries || self.empty) {
        return [NSDate date];
    }

    NSDate *timestamp = self.leadingNotificationEntry.timestamp;
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

    return self.leadingNotificationEntry.timeZone;
}

- (BOOL)hasCustomActions {
    if (!self.entries || self.empty) {
        return NO;
    }

    return self.leadingNotificationEntry.hasCustomActions;
}

- (NSArray<NCNotificationAction *> *)customActions {
    if (!self.entries || self.empty) {
        return nil;
    }

    return self.leadingNotificationEntry.customActions;
}

- (BOOL)isEmpty {
    return self.entries.count < 1;
}

#pragma mark - Entry Helpers

- (NUANotificationEntry *)leadingNotificationEntry {
    // Simply return first object
    return self.entries.firstObject;
}

- (NSUInteger)_existingIndexForNotificationEntry:(NUANotificationEntry *)entry {
    return [self.entries indexOfObjectPassingTest:^(NUANotificationEntry *obj, NSUInteger idx, BOOL *stop) {
        return [obj isEqual:entry];
    }];
}

- (NSUInteger)_insertionIndexForNotificationEntry:(NUANotificationEntry *)entry {
    return [self.entries indexOfObject:entry inSortedRange:NSMakeRange(0, self.entries.count) options:(NSBinarySearchingFirstEqual | NSBinarySearchingInsertionIndex) usingComparator:^(NUANotificationEntry *entry1, NUANotificationEntry *entry2) {
        return [entry1 compare:entry2];
    }];
}

#pragma mark - Entry Management

- (BOOL)containsRequest:(NCNotificationRequest *)request {
    NUANotificationEntry *entry = [NUANotificationEntry notificationEntryFromRequest:request];
    return [self _existingIndexForNotificationEntry:entry] != NSNotFound;
}

- (void)updateWithNewRequest:(NCNotificationRequest *)request {
    // Construct entry and check if contains
    if (![self containsRequest:request]) {
        // New request
        NUANotificationEntry *entry = [NUANotificationEntry notificationEntryFromRequest:request];
        NSUInteger insertionIndex = [self _insertionIndexForNotificationEntry:entry];

        NSMutableArray<NUANotificationEntry *> *entries = [self.entries mutableCopy];
        [entries insertObject:entry atIndex:insertionIndex];
        _entries = [entries copy];
    } else {
        // Modify existing one
        [self modifyExistingEntryWithRequest:request];
    }
}

- (void)modifyExistingEntryWithRequest:(NCNotificationRequest *)request {
    NUANotificationEntry *entry = [NUANotificationEntry notificationEntryFromRequest:request];
    NSUInteger existingIndex = [self _existingIndexForNotificationEntry:entry];
    if (existingIndex == NSNotFound) {
        // Guess we never had it, strange
        return;
    }

    NSUInteger insertionIndex = [self _insertionIndexForNotificationEntry:entry];
    NSMutableArray<NUANotificationEntry *> *entries = [self.entries mutableCopy];
    if (insertionIndex == existingIndex) {
        // Same indicies
        [entries replaceObjectAtIndex:insertionIndex withObject:entry];
    } else {
        // Remove old add new
        NUANotificationEntry *oldEntry = entries[existingIndex];
        [entries insertObject:entry atIndex:insertionIndex];
        [entries removeObject:oldEntry];
    }

    _entries = [entries copy];
}

- (void)removeRequest:(NCNotificationRequest *)request {
    NUANotificationEntry *entry = [NUANotificationEntry notificationEntryFromRequest:request];
    NSUInteger existingIndex = [self _existingIndexForNotificationEntry:entry];
    if (existingIndex == NSNotFound) {
        // Cant remove something i dont have
        return;
    }

    // Remove object
    NSMutableArray<NUANotificationEntry *> *entries = [self.entries mutableCopy];
    [entries removeObjectAtIndex:existingIndex];
    _entries = [entries copy];
}

@end