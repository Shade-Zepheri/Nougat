@class NCNotificationListCell, NCNotificationRequest;

@interface NCNotificationGroupList : NSObject

- (NCNotificationListCell *)_currentCellForNotificationRequest:(NCNotificationRequest *)request;

@end