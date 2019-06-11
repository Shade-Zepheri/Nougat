#import "NUADoNotDisturbToggle.h"
#import <UIKit/UIImage+Private.h>

@implementation NUADoNotDisturbToggle

#pragma mark - Init

- (instancetype)init {
    return [super initWithSwitchIdentifier:@"com.a3tweaks.switch.do-not-disturb"];
}

#pragma mark - Toggle

- (NSString *)displayName {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    return [bundle localizedStringForKey:@"NOUGAT_STATUS_DO_NOT_DISTURB_DISPLAY_NAME" value:@"Do Not Disturb" table:nil];
}

- (NSURL *)settingsURL {
    return [NSURL URLWithString:@"prefs:root=DO_NOT_DISTURB"];
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