#import "NCNotificationDestinationDelegate.h"

@protocol NCNotificationAlertDestinationDelegate <NCNotificationDestinationDelegate>

@optional
- (void)destination:(id)destination willPresentNotificationRequest:(NCNotificationRequest *)request suppressAlerts:(BOOL)suppressAlerts;
- (void)destination:(id)destination didPresentNotificationRequest:(NCNotificationRequest *)request;
- (void)destination:(id)destination willDismissNotificationRequest:(NCNotificationRequest *)request;
- (void)destination:(id)destination didDismissNotificationRequest:(NCNotificationRequest *)request;
- (void)destination:(id)destination willPresentNotificationRequest:(NCNotificationRequest *)request;

@required
- (void)destinationDidBecomeReadyToReceiveNotifications:(id)destination;
- (void)destination:(id)destination didBecomeReadyToReceiveNotificationsPassingTest:(/*^block*/id)test;
- (void)destination:(id)destination didBecomeReadyToReceiveNotificationsCoalescedWith:(id)comparator;

@end