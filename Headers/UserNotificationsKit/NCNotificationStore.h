@class NCNotificationSection;

@interface NCNotificationStore : NSObject
@property (strong, nonatomic) NSMutableDictionary<NSString *, NCNotificationSection *> *notificationSections;
@property (readonly, nonatomic) NSUInteger sectionsCount; 
@property (readonly, nonatomic) NSUInteger notificationsCount; 

@end