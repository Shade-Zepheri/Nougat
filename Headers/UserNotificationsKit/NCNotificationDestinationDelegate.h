@protocol NCNotificationDestination;
@class NCNotificationAction, NCNotificationRequest, NCNotificationSection;

@protocol NCNotificationDestinationDelegate <NSObject>
@optional
- (void)destination:(id<NCNotificationDestination>)destination setAllowsNotifications:(BOOL)allowsNotifications forSectionIdentifier:(NSString *)sectionID;
- (void)destination:(id<NCNotificationDestination>)destination setDeliverQuietly:(BOOL)deliverQuietly forSectionIdentifier:(NSString *)sectionID;
- (void)destination:(id<NCNotificationDestination>)destination setAllowsCriticalAlerts:(BOOL)allowsCriticalAlerts forSectionIdentifier:(NSString *)sectionID;

@required
- (void)destination:(id<NCNotificationDestination>)destination requestPermissionToExecuteAction:(NCNotificationAction *)action forNotificationRequest:(NCNotificationRequest *)request withParameters:(NSDictionary *)parameters completion:(void(^)(BOOL success))completion;
- (void)destination:(id<NCNotificationDestination>)destination executeAction:(NCNotificationAction *)action forNotificationRequest:(NCNotificationRequest *)request requestAuthentication:(BOOL)requestAuthentication withParameters:(NSDictionary *)parameters completion:(void(^)(BOOL success))completion; // iOS 11+
- (void)destination:(id<NCNotificationDestination>)destination executeAction:(NCNotificationAction *)action forNotificationRequest:(NCNotificationRequest *)request withParameters:(NSDictionary *)parameters completion:(void(^)(BOOL success))completion; // iOS 10
- (void)destination:(id<NCNotificationDestination>)destination requestsClearingNotificationRequests:(NSMutableSet<NCNotificationRequest *> *)requests;
- (void)destination:(id<NCNotificationDestination>)destination requestsClearingNotificationRequests:(NSMutableSet<NCNotificationRequest *> *)requests fromDestinations:(NSMutableSet<id<NCNotificationDestination>> *)destinations;
- (void)destination:(id<NCNotificationDestination>)destination requestsClearingNotificationRequestsFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate inSections:(NSMutableSet<NCNotificationSection *> *)sections;
- (void)destination:(id<NCNotificationDestination>)destination requestsClearingNotificationRequestsInSections:(NSMutableSet<NCNotificationSection *> *)sections;

@end