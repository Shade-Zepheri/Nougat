@class NCCoalescedNotification;

@interface NCNotificationSection : NSObject
@property (strong, nonatomic) NSMutableDictionary<NSString *, NCCoalescedNotification *> *coalescedNotifications;
@property (readonly, nonatomic) NSUInteger notificationsCount;

@end