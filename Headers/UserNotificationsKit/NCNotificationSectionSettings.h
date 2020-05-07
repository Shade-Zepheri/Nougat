@interface NCNotificationSectionSettings : NSObject
@property (readonly, nonatomic) BOOL notificationsEnabled;
@property (readonly, nonatomic) BOOL criticalAlertsEnabled;
@property (readonly, nonatomic) BOOL showsInNotificationCenter;
@property (readonly, nonatomic) BOOL showsInLockScreen;
@property (readonly, nonatomic) NSInteger subSectionPriority;

@property (copy, readonly, nonatomic) NSString *sectionIdentifier;
@property (copy, readonly, nonatomic) NSString *subSectionIdentifier;
@property (copy, readonly, nonatomic) NSString *displayName;
@property (copy, readonly, nonatomic) NSDictionary *settings;
@property (copy, readonly, nonatomic) NSSet *subSectionSettings;

@property (readonly, nonatomic) UIImage *settingsIcon;
@property (readonly, nonatomic) BOOL isDeliveredQuietly;

@end