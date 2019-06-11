#import "NUABluetoothToggle.h"
#import <UIKit/UIImage+Private.h>

@implementation NUABluetoothToggle

#pragma mark - Init

- (instancetype)init {
    return [super initWithSwitchIdentifier:@"com.a3tweaks.switch.bluetooth"];
}

#pragma mark - Toggle

- (NSString *)displayName {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    return [bundle localizedStringForKey:@"NOUGAT_STATUS_BLUETOOTH_DISPLAY_NAME" value:@"Bluetooth" table:nil];
}

- (NSURL *)settingsURL {
    return [NSURL URLWithString:@"prefs:root=BLUETOOTH"];
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