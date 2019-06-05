#import "NUARotationLockToggle.h"
#import <UIKit/UIImage+Private.h>

@implementation NUARotationLockToggle

#pragma mark - Init

- (instancetype)init {
    return [super initWithSwitchIdentifier:@"com.a3tweaks.switch.rotation-lock"];
}

#pragma mark - Toggle

- (BOOL)isInverted {
    return YES;
}

- (NSString *)displayName {
    return @"Rotation Lock";
}

- (UIImage *)icon {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    return [UIImage imageNamed:@"On" inBundle:bundle];
}

- (UIImage *)selectedIcon {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *imageName = [NSString stringWithFormat:@"Off-%@", self.usingDark ? @"Dark" : @"Light"];
    return [UIImage imageNamed:imageName inBundle:bundle];
}

@end