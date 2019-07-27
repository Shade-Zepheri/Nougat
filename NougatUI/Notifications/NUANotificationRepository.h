#import <UIKit/UIKit.h>
#import "NUACoalescedNotification.h"
#import "NUANotificationEntry.h"
#import <UserNotificationsKit/UserNotificationsKit.h>

@protocol NUANotificationsObserver <NSObject>

- (void)notificationRepositoryAddedNotification:(NUACoalescedNotification *)newNotification;
- (void)notificationRepositoryUpdatedNotification:(NUACoalescedNotification *)updatedNotification;

@end

typedef void (^NUANotificationsObserverHandler)(id<NUANotificationsObserver> observer);

@interface NUANotificationRepository : NSObject {
    NSHashTable *_observers;
    dispatch_queue_t _queue;
    dispatch_queue_t _callOutQueue;
    NSDictionary<NSString *, NSArray<NUACoalescedNotification *> *> *_notifications;
}

@property (class, strong, readonly) NUANotificationRepository *defaultRepository;
@property (copy, readonly, nonatomic) NSDictionary<NSString *, NSArray<NUACoalescedNotification *> *> *notifications;

- (void)addObserver:(id<NUANotificationsObserver>)observer;
- (void)removeObserver:(id<NUANotificationsObserver>)observer;

- (BOOL)insertNotificationRequest:(NCNotificationRequest *)request forCoalescedNotification:(NCCoalescedNotification *)coalescedNotification;

@end