#import "NUAToggleInstance.h"

@implementation NUAToggleInstance

#pragma mark - Initialization

- (instancetype)initWithToggleInfo:(NUAToggleInfo *)toggleInfo toggle:(NUAToggleButton *)toggle {
    self = [super init];
    if (self) {
        // Set properties
        _toggleInfo = toggleInfo;
        _toggle = toggle;
    }

    return self;
}

@end