#import <Preferences/PSListController.h>
#import <NougatServices/NougatServices.h>

@interface NUASortOrderController : PSListController
@property (strong, readonly, nonatomic) NUAPreferenceManager *preferences;
@property (strong, readonly, nonatomic) NSMutableArray<NSString *> *enabledToggles;
@property (strong, readonly, nonatomic) NSMutableArray<NSString *> *disabledToggles;

@end
