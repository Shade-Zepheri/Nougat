// Bunch of methods, too lazy to fill them all out
@class NCNotificationAction, NCNotificationRequest;

@protocol NCNotificationDestinationDelegate <NSObject>
@optional
- (void)destination:(id)destination setAllowsNotifications:(BOOL)allowsNotifications forSectionIdentifier:(NSString *)sectionID;
- (void)destination:(id)destination setDeliverQuietly:(BOOL)deliverQuietly forSectionIdentifier:(NSString *)sectionID;
- (void)destination:(id)arg1 setAllowsCriticalAlerts:(BOOL)allowsCriticalAlerts forSectionIdentifier:(NSString *)sectionID;

@required
- (void)destination:(id)destination requestPermissionToExecuteAction:(NCNotificationAction *)action forNotificationRequest:(NCNotificationRequest *)request withParameters:(NSDictionary *)parameters completion:(void(^)(void))completion;
- (void)destination:(id)destination executeAction:(NCNotificationAction *)action forNotificationRequest:(NCNotificationRequest *)request requestAuthentication:(BOOL)requestAuthentication withParameters:(NSDictionary *)parameters completion:(void(^)(void))completion; // iOS 11+
- (void)destination:(id)destination executeAction:(NCNotificationAction *)action forNotificationRequest:(NCNotificationRequest *)request withParameters:(NSDictionary *)parameters completion:(void(^)(void))completion; // iOS 10
- (void)destination:(id)destination requestsClearingNotificationRequests:(NSArray<NCNotificationRequest *> *)requests;
- (void)destination:(id)destination requestsClearingNotificationRequests:(NSArray<NCNotificationRequest *> *)requests fromDestinations:(id)destinations;
- (void)destination:(id)destination requestsClearingNotificationRequestsFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate inSections:(id)sections;
- (void)destination:(id)destination requestsClearingNotificationRequestsInSections:(id)sections;

@end