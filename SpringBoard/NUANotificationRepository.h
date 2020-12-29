#import <UIKit/UIKit.h>
#import <BoardServices/BoardServices.h>
#import <NougatUI/NougatUI.h>
#import <UserNotificationsKit/UserNotificationsKit.h>

typedef void (^NUANotificationsObserverHandler)(id<NUANotificationsObserver> observer);

@interface NUANotificationRepository : NSObject <NCNotificationDestination, NUANotificationsProvider>
@property (copy, readonly, nonatomic) NSSet<NUACoalescedNotification *> *notifications;

@property (readonly, nonatomic) NSString *identifier;
@property (weak, nonatomic) id<NCNotificationDestinationDelegate> delegate;
@property (readonly, nonatomic) BSServiceConnectionEndpoint *endpoint;

- (void)addObserver:(id<NUANotificationsObserver>)observer;
- (void)removeObserver:(id<NUANotificationsObserver>)observer;

- (void)executeAction:(NCNotificationAction *)action forNotificationRequest:(NCNotificationRequest *)request;

- (void)purgeAllNotifications;

@end