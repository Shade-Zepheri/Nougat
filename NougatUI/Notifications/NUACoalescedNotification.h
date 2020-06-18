#import <UIKit/UIKit.h>
#import "NUANotificationEntry.h"
#import <UserNotificationsKit/UserNotificationsKit.h>

typedef NS_ENUM(NSUInteger, NUANotificationType) {
    NUANotificationTypeNotification,
    NUANotificationTypeMedia
};

@interface NUACoalescedNotification : NSObject <NSCopying>
@property (copy, readonly, nonatomic) NSString *sectionID;
@property (copy, readonly, nonatomic) NSString *threadID;
@property (copy, readonly, nonatomic) NSString *title;
@property (copy, readonly, nonatomic) NSString *message;
@property (readonly, nonatomic) UIImage *icon;
@property (readonly, nonatomic) BOOL hasAttachmentImage;
@property (readonly, nonatomic) UIImage *attachmentImage;
@property (readonly, nonatomic) NSDate *timestamp;
@property (readonly, nonatomic) NSTimeZone *timeZone;
@property (readonly, nonatomic) BOOL hasCustomActions;
@property (copy, readonly, nonatomic) NSArray<NCNotificationAction *> *customActions;
@property (strong, readonly, nonatomic) NUANotificationEntry *leadingNotificationEntry;
@property (readonly, nonatomic) NSArray<NUANotificationEntry *> *allEntries;
@property (assign, nonatomic) NUANotificationType type;
@property (getter=isEmpty, readonly, nonatomic) BOOL empty;

+ (instancetype)mediaNotification;

+ (instancetype)coalescedNotificationFromNotification:(NCCoalescedNotification *)notification;
+ (instancetype)coalescedNotificationFromRequest:(NCNotificationRequest *)request;
- (instancetype)initFromNotification:(NCCoalescedNotification *)notification;

- (BOOL)containsRequest:(NCNotificationRequest *)request;
- (void)updateWithNewRequest:(NCNotificationRequest *)request;
- (void)removeRequest:(NCNotificationRequest *)request;

- (NSComparisonResult)compare:(NUACoalescedNotification *)otherNotification;

@end