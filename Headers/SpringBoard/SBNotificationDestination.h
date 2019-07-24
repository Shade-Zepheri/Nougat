@class SBNCAlertingController;

@protocol SBNotificationDestination <NSObject>
@property (weak, nonatomic) SBNCAlertingController *alertingController; 
@required

- (SBNCAlertingController *)alertingController;
- (void)setAlertingController:(SBNCAlertingController *)alertingController;

@end