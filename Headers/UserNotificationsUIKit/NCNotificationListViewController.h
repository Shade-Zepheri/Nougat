@class NCCoalescedNotification, NCNotificationListViewController, NCNotificationAction, NCNotificationRequest, NCNotificationListCell;

@protocol NCNotificationListViewControllerDestinationDelegate <NSObject>
// Sooooooooooo many options here
- (void)notificationListViewController:(NCNotificationListViewController *)listViewController requestsExecuteAction:(NCNotificationAction *)action forNotificationRequest:(NCNotificationRequest *)request requestAuthentication:(BOOL)requestAuthentication withParameters:(NSDictionary *)parameters completion:(void(^)())completion;

@end

@interface NCNotificationListViewController : UICollectionViewController
@property (weak, nonatomic) id<NCNotificationListViewControllerDestinationDelegate> destinationDelegate;

- (void)removeNotificationRequest:(NCNotificationRequest *)request forCoalescedNotification:(NCCoalescedNotification *)coalescedNotification;

- (NSIndexPath *)indexPathForNotificationRequest:(NCNotificationRequest *)notificationRequest;

// Added by me
- (NCNotificationListCell *)nua_notificationListCellForRequest:(NCNotificationRequest *)request;

@end