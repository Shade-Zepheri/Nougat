#import <UserNotificationsKit/NCNotificationDestination.h>

@class NCNotificationAction, NCNotificationRequest;

@interface SBNotificationBannerDestination : NSObject <NCNotificationDestination>
@property (weak, nonatomic) id<NCNotificationDestinationDelegate> delegate;

@end