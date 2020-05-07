#import "NCNotificationDestinationDelegate.h"
#import "NCNotificationDestination.h"

@class NCNotificationStore;

@interface NCNotificationDispatcher : NSObject <NCNotificationDestinationDelegate>
@property (strong, nonatomic) NCNotificationStore *notificationStore;

- (void)registerDestination:(id<NCNotificationDestination>)destination;
- (void)unregisterDestination:(id<NCNotificationDestination>)destination;

- (void)setDestination:(id<NCNotificationDestination>)destination enabled:(BOOL)enabled;

@end