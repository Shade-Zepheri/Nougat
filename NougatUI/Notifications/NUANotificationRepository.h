#import <UIKit/UIKit.h>
#import "NUACoalescedNotification.h"
#import "NUANotificationEntry.h"
#import <BoardServices/BoardServices.h>
#import <UserNotificationsKit/UserNotificationsKit.h>

@protocol NUANotificationsObserver <NSObject>

- (void)notificationRepositoryAddedNotification:(NUACoalescedNotification *)newNotification;
- (void)notificationRepositoryUpdatedNotification:(NUACoalescedNotification *)updatedNotification;
- (void)notificationRepositoryRemovedNotification:(NUACoalescedNotification *)removedNotification;

@end

typedef void (^NUANotificationsObserverHandler)(id<NUANotificationsObserver> observer);

@interface NUANotificationRepository : NSObject <NCNotificationDestination>
@property (class, strong, readonly) NUANotificationRepository *defaultRepository;
@property (copy, readonly, nonatomic) NSSet<NUACoalescedNotification *> *notifications;

@property (readonly, nonatomic) NSString *identifier;
@property (weak, nonatomic) id<NCNotificationDestinationDelegate> delegate;
@property (readonly, nonatomic) BSServiceConnectionEndpoint *endpoint;

- (void)addObserver:(id<NUANotificationsObserver>)observer;
- (void)removeObserver:(id<NUANotificationsObserver>)observer;

- (void)executeAction:(NCNotificationAction *)action forNotificationRequest:(NCNotificationRequest *)request;

- (BOOL)insertNotificationRequest:(NCNotificationRequest *)request forCoalescedNotification:(NCCoalescedNotification *)coalescedNotification;
- (void)removeNotificationRequest:(NCNotificationRequest *)request forCoalescedNotification:(NCCoalescedNotification *)coalescedNotification;

- (void)purgeAllNotifications;

@end