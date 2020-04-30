#import <UIKit/UIKit.h>
#import <UIKit/UIKit+Private.h>
#import <math.h>

/**
 * Converts the given `location` from the coordinate system of 
 * @c fromOrientation to the coordinate system of @c toOrientation
 *
 * @param location The given location
 * @param fromOrientation The prior orientation
 * @param toOrientation The current orientation
 * @return The location translated the current orientation
 */
static inline CGPoint NUAConvertPointFromOrientationToOrientation(CGPoint location, UIInterfaceOrientation fromOrientation, UIInterfaceOrientation toOrientation) {
    if (fromOrientation == toOrientation) {
        return location;
    }

    CGFloat rotatedX = 0.0;
    CGFloat rotatedY = 0.0;
    switch (toOrientation) {
        case UIInterfaceOrientationUnknown:
        case UIInterfaceOrientationPortrait: {
            rotatedX = location.x;
            rotatedY = location.y;
            break;
        }
        case UIInterfaceOrientationPortraitUpsideDown: {
            rotatedX = CGRectGetWidth([UIScreen mainScreen].bounds) - location.x;
            rotatedY = CGRectGetHeight([UIScreen mainScreen].bounds) - location.y;
            break;
        }
        case UIInterfaceOrientationLandscapeLeft: {
            rotatedX = CGRectGetHeight([UIScreen mainScreen]._referenceBounds) - location.y;
            rotatedY = location.x;
            break;
        }
        case UIInterfaceOrientationLandscapeRight: {
            rotatedX = location.y;
            rotatedY = CGRectGetWidth([UIScreen mainScreen]._referenceBounds) - location.x;
            break;
        }
    }

    return CGPointMake(rotatedX, rotatedY);
}

/**
 * In iOS 10, mainScreen's bounds do not properly adjust for orientation
 * SpringBoard retains its orientation and ignores any orientation changes of current apps
 * Not sure if this only applies to iOS 10 iphones, more testing is required
 *
 * @param orientation Current orientation
 * @return Screen bounds adjusted to the given orientation
 */
static inline CGRect NUAScreenBoundsAdjustedForOrientation(UIInterfaceOrientation orientation) {
    CGRect referenceBounds = [UIScreen mainScreen]._referenceBounds;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        return CGRectMake(0, 0, CGRectGetHeight(referenceBounds), CGRectGetWidth(referenceBounds));
    } else {
        return referenceBounds;
    }
}

/**
 * Get the current screen width adjusted for 
 * @c orientation
 *
 * @param orientation Current orientation
 * @return The screen width for the provided orientation
 */
static inline CGFloat NUAGetScreenWidthForOrientation(UIInterfaceOrientation orientation) {
    return CGRectGetWidth(NUAScreenBoundsAdjustedForOrientation(orientation));
}

/**
 * Get the current screen height adjusted for 
 * @c orientation
 *
 * @param orientation Current orientation
 * @return The screen height for the provided orientation
 */
static inline CGFloat NUAGetScreenHeightForOrientation(UIInterfaceOrientation orientation) {
    return CGRectGetHeight(NUAScreenBoundsAdjustedForOrientation(orientation));
}