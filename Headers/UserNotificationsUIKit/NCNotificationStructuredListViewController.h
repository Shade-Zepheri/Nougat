#import <UIKit/UIKit.h>

@class NCNotificationStructuredListViewController, NCNotificationAction, NCNotificationRequest;
@protocol NCNotificationStructuredListViewControllerDelegate <UIScrollViewDelegate>
@required

- (void)notificationStructuredListViewController:(NCNotificationStructuredListViewController *)structuredListViewController requestsExecuteAction:(NCNotificationAction *)action forNotificationRequest:(NCNotificationRequest *)request requestAuthentication:(BOOL)requestAuthentication withParameters:(NSDictionary *)parameters completion:(void(^)())completion;

@end

@interface NCNotificationStructuredListViewController : UIViewController
@property (weak, nonatomic) id<NCNotificationStructuredListViewControllerDelegate> delegate;

- (void)insertNotificationRequest:(NCNotificationRequest *)request;
- (void)modifyNotificationRequest:(NCNotificationRequest *)request;
- (void)removeNotificationRequest:(NCNotificationRequest *)request;

@end