#import "NCNotificationDestinationDelegate.h"

@class NCCoalescedNotification, NCNotificationRequest, NCNotificationSectionSettings;

@protocol NCNotificationDestination <NSObject>
@property (readonly, nonatomic) NSString *identifier;
@property (weak, nonatomic) id<NCNotificationDestinationDelegate> delegate;

- (BOOL)canReceiveNotificationRequest:(NCNotificationRequest *)request;

// iOS 10-12
- (void)postNotificationRequest:(NCNotificationRequest *)request forCoalescedNotification:(NCCoalescedNotification *)coalescedNotification;
- (void)modifyNotificationRequest:(NCNotificationRequest *)request forCoalescedNotification:(NCCoalescedNotification *)coalescedNotification;
- (void)withdrawNotificationRequest:(NCNotificationRequest *)request forCoalescedNotification:(NCCoalescedNotification *)coalescedNotification;

// iOS 13
- (void)postNotificationRequest:(NCNotificationRequest *)request;
- (void)modifyNotificationRequest:(NCNotificationRequest *)request;
- (void)withdrawNotificationRequest:(NCNotificationRequest *)request;

@optional

- (BOOL)interceptsQueueRequest:(NCNotificationRequest *)request;

// iOS 10-11
- (void)updateNotificationSectionSettings:(NCNotificationSectionSettings *)updatedSettings;

// iOS 12-13
- (void)updateNotificationSectionSettings:(NCNotificationSectionSettings *)updatedSettings previousSectionSettings:(NCNotificationSectionSettings *)previousSettings;

@end