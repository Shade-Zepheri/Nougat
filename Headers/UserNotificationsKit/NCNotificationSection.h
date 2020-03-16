@class NCCoalescedNotification, NCNotificationRequest;

@interface NCNotificationSection : NSObject
//  iOS 10-12
@property (strong, nonatomic) NSMutableDictionary<NSString *, NCCoalescedNotification *> *coalescedNotifications;
// iOS 13
@property (nonatomic,retain) NSMutableDictionary<NSString *, NCNotificationRequest *> *requests;

@property (readonly, nonatomic) NSUInteger notificationsCount;

@end