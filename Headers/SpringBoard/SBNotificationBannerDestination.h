#import <UserNotificationsKit/NCNotificationDestinationDelegate.h>

@class NCNotificationAction, NCNotificationRequest;

@interface SBNotificationBannerDestination : NSObject
@property (weak, nonatomic) id<NCNotificationDestinationDelegate> delegate;

// Method added by Nougat
- (void)nua_executeAction:(NCNotificationAction *)action forNotificationRequest:(NCNotificationRequest *)request;

@end