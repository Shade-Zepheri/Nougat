#import <UIKit/UIView.h>
#import "NUASystemServicesProvider.h"
#import <NougatServices/NougatServices.h>

@interface NUANotificationShadeModuleView : UIView
@property (strong, readonly, nonatomic) NUAPreferenceManager *notificationShadePreferences;
@property (strong, readonly, nonatomic) id<NUASystemServicesProvider> systemServicesProvider;

- (instancetype)initWithPreferences:(NUAPreferenceManager *)preferences systemServicesProvider:(id<NUASystemServicesProvider>)systemServicesProvider;

@end