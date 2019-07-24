#import "SBNotificationDestination.h"
#import <UserNotificationsKit/NCNotificationDestinationDelegate.h>

@interface SBDashBoardNotificationDispatcher : NSObject <SBNotificationDestination>
@property (weak ,nonatomic) id<NCNotificationDestinationDelegate> delegate;

@end