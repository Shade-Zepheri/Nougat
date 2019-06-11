#import "NUADataToggle.h"
#import <UIKit/UIImage+Private.h>

@implementation NUADataToggle

#pragma mark - Init

- (instancetype)init {
    return [super initWithSwitchIdentifier:@"com.a3tweaks.switch.cellular-data"];
}

#pragma mark - Toggle

- (NSString *)displayName {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    return [bundle localizedStringForKey:@"NOUGAT_STATUS_DATA_DISPLAY_NAME" value:@"Mobile Data" table:nil];
}

- (NSURL *)settingsURL {
    return [NSURL URLWithString:@"prefs:root=MOBILE_DATA_SETTINGS_ID"];
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