#import "NUANotificationEntry.h"

@implementation NUANotificationEntry

#pragma mark - Init

+ (instancetype)notificationEntryFromRequest:(NCNotificationRequest *)request {
    return [[self alloc] initFromRequest:request];
}

- (instancetype)initFromRequest:(NCNotificationRequest *)request {
    self = [super init];
    if (self) {
        _timestamp = request.timestamp;

        // Get info from content
        NCNotificationContent *content = request.content;
        _title = content.title;
        _message = content.message;
        _icon = content.icon;
        _attachmentImage = content.attachmentImage;
    }

    return self;
}

@end