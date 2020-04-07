#import <UIKit/UIView.h>
#import <NougatServices/NougatServices.h>

@interface NUANotificationShadeModuleView : UIView
@property (strong, readonly, nonatomic) NUAPreferenceManager *notificationShadePreferences;

- (instancetype)initWithPreferences:(NUAPreferenceManager *)preferences;

@end