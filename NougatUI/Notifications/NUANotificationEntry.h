#import <UIKit/UIKit.h>
#import <UserNotificationsKit/UserNotificationsKit.h>

@interface NUANotificationEntry : NSObject
@property (strong, readonly, nonatomic) NCNotificationRequest *request;
@property (copy, readonly, nonatomic) NSString *title;
@property (copy, readonly, nonatomic) NSString *message;
@property (readonly, nonatomic) UIImage *icon;
@property (readonly, nonatomic) UIImage *attachmentImage;
@property (strong, readonly, nonatomic) NSDate *timestamp;

+ (instancetype)notificationEntryFromRequest:(NCNotificationRequest *)request;

@end