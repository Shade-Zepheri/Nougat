#import "NUACoalescedNotification.h"

@protocol NUANotificationsObserver <NSObject>

- (void)notificationRepositoryAddedNotification:(NUACoalescedNotification *)newNotification;
- (void)notificationRepositoryUpdatedNotification:(NUACoalescedNotification *)updatedNotification;
- (void)notificationRepositoryRemovedNotification:(NUACoalescedNotification *)removedNotification;

@end

@protocol NUANotificationsProvider <NSObject>
@property (copy, readonly, nonatomic) NSSet<NUACoalescedNotification *> *notifications;

@required

- (NSSet<NUACoalescedNotification *> *)notifications;

- (void)addObserver:(id<NUANotificationsObserver>)observer;
- (void)removeObserver:(id<NUANotificationsObserver>)observer;

- (void)executeAction:(NCNotificationAction *)action forNotificationRequest:(NCNotificationRequest *)request;

- (void)purgeAllNotifications;

@end