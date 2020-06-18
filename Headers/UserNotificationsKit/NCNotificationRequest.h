@class NCNotificationAction, NCNotificationContent;

@interface NCNotificationRequest : NSObject
@property (readonly, nonatomic) BOOL hasAttachments; 
@property (copy, readonly, nonatomic) NSString *sectionIdentifier;
@property (copy, readonly, nonatomic) NSString *notificationIdentifier;
@property (copy, readonly, nonatomic) NSString *threadIdentifier;
@property (readonly, nonatomic) NSDate *timestamp;
@property (readonly, nonatomic) NCNotificationContent *content;
@property (readonly, nonatomic) NCNotificationAction *clearAction;
@property (readonly, nonatomic) NCNotificationAction *closeAction;
@property (readonly, nonatomic) NCNotificationAction *defaultAction;
@property (readonly, nonatomic) NCNotificationAction *silenceAction;
@property (copy, readonly, nonatomic) NSDictionary<NSString *, NSArray<NCNotificationAction *> *> *supplementaryActions;

- (BOOL)matchesRequest:(NCNotificationRequest *)request;

@end