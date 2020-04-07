#import "NUANotificationShadeModuleView.h"

@implementation NUANotificationShadeModuleView

- (instancetype)initWithPreferences:(NUAPreferenceManager *)preferences {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        // Pretty barebones class, just set our property
        _notificationShadePreferences = preferences;
    }

    return self;
}

@end