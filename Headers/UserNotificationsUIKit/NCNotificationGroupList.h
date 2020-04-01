@class NCNotificationListCell, NCNotificationRequest;

@interface NCNotificationGroupList : NSObject

- (void)_performDefaultActionForNotificationRequest:(NCNotificationRequest *)notificationRequest withCompletion:(void(^)(void))completion;
- (void)_clearNotificationRequest:(NCNotificationRequest *)notificationRequest withCompletion:(void(^)(void))completion;

- (NCNotificationListCell *)_currentCellForNotificationRequest:(NCNotificationRequest *)notificationRequest;

@end