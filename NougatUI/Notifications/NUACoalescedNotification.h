#import <UIKit/UIKit.h>
#import "NUANotificationEntry.h"
#import <UserNotificationsKit/UserNotificationsKit.h>

typedef NS_ENUM(NSUInteger, NUANotificationType) {
    NUANotificationTypeNotification,
    NUANotificationTypeMedia
};

@interface NUACoalescedNotification : NSObject
@property (copy, readonly, nonatomic) NSString *sectionID;
@property (copy, readonly, nonatomic) NSString *threadID;
@property (copy, readonly, nonatomic) NSString *title;
@property (copy, readonly, nonatomic) NSString *message;
@property (readonly, nonatomic) UIImage *icon;
@property (readonly, nonatomic) UIImage *attachmentImage;
@property (readonly, nonatomic) NSDate *timestamp;
@property (copy, readonly, nonatomic) NSArray<NUANotificationEntry *> *entries;
@property (assign, nonatomic) NUANotificationType type;
@property (getter=isEmpty, readonly, nonatomic) BOOL empty;

+ (instancetype)mediaNotification;

+ (instancetype)coalescedNotificationFromNotification:(NCCoalescedNotification *)notification;
- (instancetype)initFromNotification:(NCCoalescedNotification *)notification;

+ (instancetype)coalescedNotificationFromRequest:(NCNotificationRequest *)request;

- (BOOL)containsRequest:(NCNotificationRequest *)request;

- (void)updateWithNewRequest:(NCNotificationRequest *)request;
- (void)removeRequest:(NCNotificationRequest *)request;

@end