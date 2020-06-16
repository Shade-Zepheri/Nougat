#import "NUAToggleDescription.h"

@implementation NUAToggleDescription

#pragma mark - Initialization

+ (instancetype)descriptionWithIdentifier:(NSString *)identifier displayName:(NSString *)displayName iconImage:(UIImage *)iconImage {
    return [[self alloc] initWithIdentifier:identifier displayName:displayName iconImage:iconImage];
}

- (instancetype)initWithIdentifier:(NSString *)identifier displayName:(NSString *)displayName iconImage:(UIImage *)iconImage {
    self = [super init];
    if (self) {
        _identifier = [identifier copy];
        _displayName = [displayName copy];
        _iconImage = [iconImage copy];
    }

    return self;
}

@end