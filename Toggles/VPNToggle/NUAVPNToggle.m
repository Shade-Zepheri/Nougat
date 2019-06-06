#import "NUAVPNToggle.h"
#import <UIKit/UIImage+Private.h>

@implementation NUAVPNToggle

#pragma mark - Init

- (instancetype)init {
    return [super initWithSwitchIdentifier:@"com.a3tweaks.switch.vpn"];
}

#pragma mark - Toggle

- (NSString *)displayName {
    return @"VPN";
}

- (NSURL *)settingsURL {
    return [NSURL URLWithString:@"prefs:root=VPN"];
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