#import <NougatServices/NougatServices.h>
#import "NUAToggleButton.h"

@interface NUAToggleInstancesProvider : NSObject
@property (copy, readonly, nonatomic) NSArray<NUAToggleButton *> *toggleInstances;
@property (strong, readonly, nonatomic) NUAPreferenceManager *notificationShadePreferences;

- (instancetype)initWithPreferences:(NUAPreferenceManager *)preferences;

@end