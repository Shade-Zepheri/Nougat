@class NCCoalescedNotification, NCNotificationListViewController, NCNotificationAction, NCNotificationRequest, NCNotificationListCell;

@protocol NCNotificationListViewControllerDestinationDelegate <NSObject>
// iOS 11-12
- (void)notificationListViewController:(NCNotificationListViewController *)listViewController requestsExecuteAction:(NCNotificationAction *)action forNotificationRequest:(NCNotificationRequest *)request requestAuthentication:(BOOL)requestAuthentication withParameters:(NSDictionary *)parameters completion:(void(^)(void))completion;

// iOS 10
- (void)notificationListViewController:(NCNotificationListViewController *)listViewController requestsExecuteAction:(NCNotificationAction *)action forNotificationRequest:(NCNotificationRequest *)request withParameters:(NSDictionary *)parameters completion:(void(^)(void))completion;

@end

@interface NCNotificationListViewController : UICollectionViewController
@property (weak, nonatomic) id<NCNotificationListViewControllerDestinationDelegate> destinationDelegate;

- (void)removeNotificationRequest:(NCNotificationRequest *)request forCoalescedNotification:(NCCoalescedNotification *)coalescedNotification;

- (NSIndexPath *)indexPathForNotificationRequest:(NCNotificationRequest *)notificationRequest;

@end