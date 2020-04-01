#import <UIKit/UIKit.h>

@class NCNotificationStructuredListViewController, NCNotificationAction, NCNotificationRequest, NCNotificationMasterList;
@protocol NCNotificationStructuredListViewControllerDelegate <UIScrollViewDelegate>
@required

- (void)notificationStructuredListViewController:(NCNotificationStructuredListViewController *)structuredListViewController requestsExecuteAction:(NCNotificationAction *)action forNotificationRequest:(NCNotificationRequest *)request requestAuthentication:(BOOL)requestAuthentication withParameters:(NSDictionary *)parameters completion:(void(^)())completion;

@end

@interface NCNotificationStructuredListViewController : UIViewController
@property (strong, nonatomic) NCNotificationMasterList *masterList;
@property (weak, nonatomic) id<NCNotificationStructuredListViewControllerDelegate> delegate;

- (void)insertNotificationRequest:(NCNotificationRequest *)request;
- (void)modifyNotificationRequest:(NCNotificationRequest *)request;
- (void)removeNotificationRequest:(NCNotificationRequest *)request;

// Added by Nougat
- (NCNotificationListCell *)nua_notificationListCellForRequest:(NCNotificationRequest *)request;

@end