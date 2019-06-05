#import <NougatServices/NougatServices.h>
#import "NUAFlipswitchToggle.h"

@interface NUAToggleInstancesProvider : NSObject
@property (class, strong, readonly) NUAToggleInstancesProvider *defaultProvider;
@property (strong, nonatomic) NUAPreferenceManager *preferences;
@property (copy, readonly, nonatomic) NSArray<NUAFlipswitchToggle *> *toggleInstances;

- (instancetype)initWithPreferences:(NUAPreferenceManager *)preferences;

@end