#import "NUANotificationShadeModuleView.h"

@implementation NUANotificationShadeModuleView

#pragma mark - Init

- (instancetype)initWithPreferences:(NUAPreferenceManager *)preferences systemServicesProvider:(id<NUASystemServicesProvider>)systemServicesProvider {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        // Pretty barebones class, just set our properties
        _notificationShadePreferences = preferences;
        _systemServicesProvider = systemServicesProvider;
    }

    return self;
}

@end