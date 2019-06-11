#import "NUAAirplaneModeToggle.h"
#import <UIKit/UIImage+Private.h>

@implementation NUAAirplaneModeToggle

#pragma mark - Init

- (instancetype)init {
    return [super initWithSwitchIdentifier:@"com.a3tweaks.switch.airplane-mode"];
}

#pragma mark - Toggle

- (NSString *)displayName {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    return [bundle localizedStringForKey:@"NOUGAT_STATUS_AIRPLANE_MODE_DISPLAY_NAME" value:@"Airplane Mode" table:nil];
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