@class NCCoalescedNotification, NCNotificationRequest;

@interface NCNotificationSection : NSObject
//  iOS 10-12
@property (strong, nonatomic) NSMutableDictionary<NSString *, NCCoalescedNotification *> *coalescedNotifications;
@property (readonly, nonatomic) NSUInteger notificationsCount;

// iOS 13
@property (strong, nonatomic) NSMutableDictionary<NSString *, NCNotificationRequest *> *requests;
@property (readonly, nonatomic) NSUInteger notificationRequestsCount;

@end