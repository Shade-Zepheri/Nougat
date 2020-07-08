#import "UIColor+Tetradic.h"

@implementation UIColor (Tetradic)

#pragma mark - Tetradic

- (NSArray<UIColor *> *)tetradicColors {
    return @[[self colorWithHueOffset:0.25], [self colorWithHueOffset:0.5], [self colorWithHueOffset:0.75]];
}

- (UIColor *)colorWithHueOffset:(CGFloat)offset {
    CGFloat hue = 0.0;
    CGFloat saturation = 0.0;
    CGFloat brightness = 0.0;
    CGFloat alpha = 0.0;
    [self getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    return [UIColor colorWithHue:fmod(hue + offset, 1) saturation:saturation brightness:brightness alpha:alpha];
}

#pragma mark - Comparisons

- (BOOL)isSimilarToColor:(UIColor *)color {
    CGFloat ourRed = 0.0;
    CGFloat ourGreen = 0.0;
    CGFloat ourBlue = 0.0;
    CGFloat ourAlpha = 0.0;
    if (![self getRed:&ourRed green:&ourGreen blue:&ourBlue alpha:&ourAlpha]) {
        return NO;
    }

    CGFloat otherRed = 0.0;
    CGFloat otherGreen = 0.0;
    CGFloat otherBlue = 0.0;
    CGFloat otherAlpha = 0.0;
    if (![color getRed:&otherRed green:&otherGreen blue:&otherBlue alpha:&otherAlpha]) {
        return NO;
    }

    return fabs(ourRed - otherRed) < 0.1804 && fabs(ourGreen - otherGreen) < 0.1804 && fabs(ourBlue - otherBlue) < 0.1804;
}

@end