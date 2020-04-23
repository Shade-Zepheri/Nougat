#import "NUAFlashlightToggle.h"
#import <UIKit/UIImage+Private.h>

@implementation NUAFlashlightToggle

#pragma mark - Init

- (instancetype)init {
    self = [super initWithSwitchIdentifier:@"com.a3tweaks.switch.flashlight"];
    if (self) {
        // If applicable, register for availability notifications (iOS 11+)
        SBUIFlashlightController *flashlightController = [NSClassFromString(@"SBUIFlashlightController") sharedInstance];
        if (flashlightController) {
            [flashlightController addObserver:self];
        }
    }

    return self;
}

#pragma mark - Flashlight Observer

- (void)flashlightAvailabilityDidChange:(BOOL)available {
    // Make sure on main queue
    dispatch_assert_queue(dispatch_get_main_queue());

    // Disable if not available
    self.enabled = available;
}

- (void)flashlightLevelDidChange:(CGFloat)newLevel {
    // Do nothing, flipswitch handles that
    return;
}

#pragma mark - Toggle

- (NSString *)displayName {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    return [bundle localizedStringForKey:@"NOUGAT_STATUS_FLASHLIGHT_DISPLAY_NAME" value:@"Flashlight" table:nil];
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