#import "NUAUserGuideController.h"

@implementation NUAUserGuideController

- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Guide" target:self];
    }

    return _specifiers;
}

@end
