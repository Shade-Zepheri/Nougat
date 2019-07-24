@protocol NCNotificationDestinationDelegate <NSObject>
@optional
-(void)destination:(id)destination setAllowsNotifications:(BOOL)allowsNotifications forSectionIdentifier:(NSString *)sectionID;
-(void)destination:(id)destination setDeliverQuietly:(BOOL)deliverQuietly forSectionIdentifier:(NSString *)sectionID;
-(void)destination:(id)arg1 setAllowsCriticalAlerts:(BOOL)allowsCriticalAlerts forSectionIdentifier:(NSString *)sectionID;

@required
-(void)destination:(id)destination requestPermissionToExecuteAction:(id)action forNotificationRequest:(id)request withParameters:(id)parameters completion:(/*^block*/id)completion;
-(void)destination:(id)destination executeAction:(id)action forNotificationRequest:(id)arg3 requestAuthentication:(BOOL)requestAuthentication withParameters:(id)parameters completion:(/*^block*/id)completion;
-(void)destination:(id)destination requestsClearingNotificationRequests:(id)requests;
-(void)destination:(id)destination requestsClearingNotificationRequests:(id)requests fromDestinations:(id)destinations;
-(void)destination:(id)destination requestsClearingNotificationRequestsFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate inSections:(id)sections;
-(void)destination:(id)destination requestsClearingNotificationRequestsInSections:(id)sections;

@end