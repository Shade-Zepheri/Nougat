@class NCCoalescedNotification, NCNotificationListViewController, NCNotificationAction, NCNotificationRequest;

@protocol NCNotificationListViewControllerDestinationDelegate <NSObject>
// Sooooooooooo many options here
- (void)notificationListViewController:(NCNotificationListViewController *)listViewController requestsExecuteAction:(NCNotificationAction *)action forNotificationRequest:(NCNotificationRequest *)request requestAuthentication:(BOOL)requestAuthentication withParameters:(NSDictionary *)parameters completion:(void(^)())completion;

@end

@interface NCNotificationListViewController : UICollectionViewController
@property (weak, nonatomic) id<NCNotificationListViewControllerDestinationDelegate> destinationDelegate;

- (void)removeNotificationRequest:(NCNotificationRequest *)request forCoalescedNotification:(NCCoalescedNotification *)coalescedNotification;

@end