#import "NUALocationToggle.h"

@implementation NUALocationToggle

#pragma mark - Init

- (instancetype)init {
    return [super initWithSwitchIdentifier:@"com.a3tweaks.switch.location"];
}

#pragma mark - Toggle

- (NSBundle *)resourceBundle {
    return [NSBundle bundleForClass:[self class]];
}

- (NSString *)displayName {
    return @"Location";
}

- (UIImage *)icon {
    return [UIImage imageNamed:@"Off" inBundle:self.resourceBundle];
}

- (UIImage *)selectedIcon {
    NSString *imageName = [NSString stringWithFormat:@"On-", self.usingDark ? @"Dark" : @"Light"];
    return [UIImage imageNamed:imageName inBundle:self.resourceBundle];
}

@end