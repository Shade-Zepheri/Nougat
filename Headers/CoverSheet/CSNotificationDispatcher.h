@class NCNotificationRequest;

@interface CSNotificationDispatcher : NSObject

- (void)postNotificationRequest:(NCNotificationRequest *)request;
- (void)withdrawNotificationRequest:(NCNotificationRequest *)request;
- (void)modifyNotificationRequest:(NCNotificationRequest *)request;

@end