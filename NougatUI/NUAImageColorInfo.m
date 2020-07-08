#import "NUAImageColorInfo.h"
#import "UIColor+Tetradic.h"
#import <HBLog.h>

@implementation NUAImageColorInfo

#pragma mark - Initialization

+ (instancetype)colorInfoFromPalette:(UIImageColorPalette *)palette {
    // Get colors
    UIColor *primaryColor = palette.primary;
    UIColor *secondaryColor = palette.secondary;
    UIColor *accentColor = palette.tertiary;

    // Determine text color
    UIColor *textColor = [primaryColor copy];
    if ([textColor isSimilarToColor:[UIColor blackColor]] || [textColor isSimilarToColor:[UIColor whiteColor]]) {
        // Try to use secondary color
        textColor = [secondaryColor copy];

        if (!textColor || [textColor isSimilarToColor:[UIColor blackColor]] || [textColor isSimilarToColor:[UIColor whiteColor]]) {
            if (@available(iOS 13, *)) {
                // Use the current label color
                textColor = [UIColor labelColor];
            } else {
                // Use black
                textColor = [UIColor blackColor];
            }
        }
    }

    // Adjust other colors
    if (!secondaryColor) {
        // No secondary or tertiary
        secondaryColor = primaryColor.tetradicColors[0];
        accentColor = primaryColor.tetradicColors[2];
    } else if (!accentColor) {
        // No tertiary
        accentColor = primaryColor.tetradicColors[2];
    }

    return [[self alloc] initWithPrimaryColor:primaryColor secondaryColor:secondaryColor accentColor:accentColor textColor:textColor];
}

- (instancetype)initWithPrimaryColor:(UIColor *)primaryColor secondaryColor:(UIColor *)secondaryColor accentColor:(UIColor *)accentColor textColor:(UIColor *)textColor {
    self = [super init];
    if (self) {
        // Simply set properties
        _primaryColor = [primaryColor copy];
        _secondaryColor = [secondaryColor copy];
        _accentColor = [accentColor copy];
        _textColor = [textColor copy];
    }

    return self;
}

#pragma mark - NSObject

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p; Primary Color: %@; Secondary Color: %@; Accent Color: %@; Text Color: %@>", self.class, self, self.primaryColor, self.secondaryColor, self.accentColor, self.textColor];
}

@end