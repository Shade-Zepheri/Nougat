#import <Preferences/Preferences.h>
#import <NougatServices/NougatServices.h>

@interface NUASortOrderController : PSListController
@property (strong, readonly, nonatomic) NUAPreferenceManager *preferences;

@end
