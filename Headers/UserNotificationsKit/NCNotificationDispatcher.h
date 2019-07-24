#import "NCNotificationDestinationDelegate.h"

@class NCNotificationStore;

@interface NCNotificationDispatcher : NSObject <NCNotificationDestinationDelegate>
@property (strong, nonatomic) NCNotificationStore *notificationStore;

@end