#import "NUANotificationEntry.h"

@implementation NUANotificationEntry

#pragma mark - Init

+ (instancetype)notificationEntryFromRequest:(NCNotificationRequest *)request {
    return [[self alloc] initFromRequest:request];
}

- (instancetype)initFromRequest:(NCNotificationRequest *)request {
    self = [super init];
    if (self) {
        _request = request;
        _timestamp = request.timestamp;

        // Get info from content
        NCNotificationContent *content = request.content;
        _title = content.title;
        _message = content.message;
        _icon = content.icon;
        _attachmentImage = content.attachmentImage;
        _timeZone = content.timeZone;

        // Get actions
        _customActions = request.supplementaryActions[@"NCNotificationActionEnvironmentMinimal"];
    }

    return self;
}

#pragma mark - Properties

- (BOOL)hasAttachmentImage {
    return self.attachmentImage != nil;
}

- (BOOL)hasCustomActions {
    return self.customActions.count > 0;
}

#pragma mark - NSObject

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p; request = %@>", self.class, self, self.request];
}

- (BOOL)isEqual:(id)object {
    if (!object || ![object isKindOfClass:self.class]) {
        // Not the same object
        return NO;
    }

    // Check if stored requests match, since isEqual is too picky
    NUANotificationEntry *entry = (NUANotificationEntry *)object;
    return [entry.request matchesRequest:self.request];
}

- (NSComparisonResult)compare:(NUANotificationEntry *)otherEntry {
    // Just compare timestamps
    return [otherEntry.timestamp compare:self.timestamp];
}

@end