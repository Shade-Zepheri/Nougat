#import <UIKit/UIKit.h>
#import "NUACoalescedNotification.h"
#import "NUANotificationEntry.h"
#import <UserNotificationsKit/UserNotificationsKit.h>

@protocol NUANotificationsObserver <NSObject>

- (void)notificationRepositoryAddedNotification:(NUACoalescedNotification *)newNotification;
- (void)notificationRepositoryUpdatedNotification:(NUACoalescedNotification *)updatedNotification removedRequest:(BOOL)removedRequest;
- (void)notificationRepositoryRemovedNotification:(NUACoalescedNotification *)removedNotification;

@end

typedef void (^NUANotificationsObserverHandler)(id<NUANotificationsObserver> observer);

@interface NUANotificationRepository : NSObject {
    NSHashTable *_observers;
    dispatch_queue_t _callOutQueue;
    BOOL _shouldRegenerate;
}

@property (class, strong, readonly) NUANotificationRepository *defaultRepository;
@property (copy, readonly, nonatomic) NSDictionary<NSString *, NSDictionary<NSString *, NUACoalescedNotification *> *> *notifications;

- (void)addObserver:(id<NUANotificationsObserver>)observer;
- (void)removeObserver:(id<NUANotificationsObserver>)observer;

- (BOOL)insertNotificationRequest:(NCNotificationRequest *)request forCoalescedNotification:(NCCoalescedNotification *)coalescedNotification;
- (void)removeNotificationRequest:(NCNotificationRequest *)request forCoalescedNotification:(NCCoalescedNotification *)coalescedNotification;

- (void)purgeAllNotifications;

@end