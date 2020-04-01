#import "UIColor+Accent.h"

@implementation UIColor (Accent)

- (UIColor *)accentColor {
    UIColor *tetradic3Color = [self colorWithHueOffset:0.75];

    CGFloat hue = 0.0;
    CGFloat saturation = 0.0;
    CGFloat brightness = 0.0;
    CGFloat alpha = 0.0;
    [tetradic3Color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];

    // Adjust brightness to 0.5
    return [UIColor colorWithHue:hue saturation:saturation brightness:0.5 alpha:alpha];
}

- (UIColor *)colorWithHueOffset:(CGFloat)offset {
    CGFloat hue = 0.0;
    CGFloat saturation = 0.0;
    CGFloat brightness = 0.0;
    CGFloat alpha = 0.0;
    [self getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    return [UIColor colorWithHue:fmod(hue + offset, 1) saturation:saturation brightness:brightness alpha:alpha];
}

@end