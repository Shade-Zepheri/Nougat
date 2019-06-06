#import "NUABatterySaverToggle.h"
#import <UIKit/UIImage+Private.h>

@implementation NUABatterySaverToggle

#pragma mark - Init

- (instancetype)init {
    return [super initWithSwitchIdentifier:@"com.a3tweaks.switch.low-power"];
}

#pragma mark - Toggle

- (NSString *)displayName {
    return @"Battery Saver";
}

- (NSURL *)settingsURL {
    return [NSURL URLWithString:@"prefs:root=BATTERY_USAGE"];
}

- (UIImage *)icon {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    return [UIImage imageNamed:@"Off" inBundle:bundle];
}

- (UIImage *)selectedIcon {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *imageName = [NSString stringWithFormat:@"On-%@", self.usingDark ? @"Dark" : @"Light"];
    return [UIImage imageNamed:imageName inBundle:bundle];
}

@end