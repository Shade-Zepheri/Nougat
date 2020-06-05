#import <UIKit/UIKit.h>
#import <UserNotificationsKit/UserNotificationsKit.h>

@interface NUANotificationEntry : NSObject
@property (strong, readonly, nonatomic) NCNotificationRequest *request;
@property (copy, readonly, nonatomic) NSString *title;
@property (copy, readonly, nonatomic) NSString *message;
@property (readonly, nonatomic) UIImage *icon;
@property (readonly, nonatomic) BOOL hasAttachmentImage;
@property (readonly, nonatomic) UIImage *attachmentImage;
@property (readonly, nonatomic) NSDate *timestamp;
@property (readonly, nonatomic) NSTimeZone *timeZone;
@property (readonly, nonatomic) BOOL hasCustomActions;
@property (copy, readonly, nonatomic) NSArray<NCNotificationAction *> *customActions;

+ (instancetype)notificationEntryFromRequest:(NCNotificationRequest *)request;

- (NSComparisonResult)compare:(NUANotificationEntry *)otherEntry;

@end