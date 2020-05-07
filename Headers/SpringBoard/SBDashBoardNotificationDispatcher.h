#import "SBNotificationDestination.h"
#import <UserNotificationsKit/NCNotificationDestinationDelegate.h>

@class NCCoalescedNotification, NCNotificationRequest;

@interface SBDashBoardNotificationDispatcher : NSObject <SBNotificationDestination>
@property (weak, nonatomic) id<NCNotificationDestinationDelegate> delegate;

- (void)postNotificationRequest:(NCNotificationRequest *)request forCoalescedNotification:(NCCoalescedNotification *)coalescedNotification;
- (void)withdrawNotificationRequest:(NCNotificationRequest *)request forCoalescedNotification:(NCCoalescedNotification *)coalescedNotification;
- (void)modifyNotificationRequest:(NCNotificationRequest *)request forCoalescedNotification:(NCCoalescedNotification *)coalescedNotification;

@end