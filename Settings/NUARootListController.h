#import <CepheiPrefs/HBRootListController.h>
#import <NougatServices/NougatServices.h>

@interface NUARootListController : HBRootListController
@property (strong, readonly, nonatomic) NUAPreferenceManager *preferences;
@property (strong, nonatomic) UIImageView *headerImageView;

@end
