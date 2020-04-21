#import <UIKit/UIKit.h>
#import <UserNotificationsKit/UserNotificationsKit.h>

@interface NUANotificationEntry : NSObject
@property (strong, readonly, nonatomic) NCNotificationRequest *request;
@property (copy, readonly, nonatomic) NSString *title;
@property (copy, readonly, nonatomic) NSString *message;
@property (readonly, nonatomic) UIImage *icon;
@property (readonly, nonatomic) UIImage *attachmentImage;
@property (readonly, nonatomic) NSDate *timestamp;
@property (readonly, nonatomic) NSTimeZone *timeZone;

+ (instancetype)notificationEntryFromRequest:(NCNotificationRequest *)request;

- (NSComparisonResult)compare:(NUANotificationEntry *)otherEntry;

@end