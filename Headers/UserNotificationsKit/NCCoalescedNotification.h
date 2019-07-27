@class NCNotificationContent, NCNotificationRequest;

@interface NCCoalescedNotification : NSObject
@property (copy, readonly, nonatomic) NSString *sectionIdentifier;
@property (copy, readonly, nonatomic) NSString *threadIdentifier;
@property (copy, readonly, nonatomic) NCNotificationContent *content;
@property (copy, readonly, nonatomic) NSArray<NCNotificationRequest *> *notificationRequests;

@end